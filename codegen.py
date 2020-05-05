from pprint import pprint

class CodeGen:
	def __init__(self, path, noOfRegs, debug=False):
		"""
			The constructor function for the class that generates assembly level code.
			Input params:
				1. self: the object of the class
				2. path: path to the file which contains the final Intermediate Code (IC)
				3. noOfRegs: the number of registers available for execution of the program
				4. debug: parameter which will output information during running, if True. Initialised to False.
		"""
		self.path = path
		f = open(path)
		self.threeAddressCode = f.readlines()
		self.noOfRegs = noOfRegs
		self.debug = debug
		self._regInit()
		self.binOp = {
			'+': "ADD",
			'-': "SUB",
			"*": "MUL",
			"/": "DIV"
		}
		# Storing the opposites of the required relational operation as IfFalse is used in 
		self.relOp = {
			'>' : "LE",
			'<' : "GE",
			'<=': "GT",
			'==': "NE",
			'>=': "LT"
		}
		self.assembly_code = []

	def _regInit(self):
		"""
			A private function which initializes the initial state of all the registers to be None.
		"""
		self.regState = { "R{}".format(i):None for i in range(self.noOfRegs) }
		if self.debug: print("The initial state of all the registers:", self.regState)

	def _printThreeAddress(self, tac):
		"""
			A function to print the three address code.
			Params:
				1. A list of shape (n, 4)
		"""
		assert len(tac) > 0
		assert len(tac[0]) == 4
		if self.debug: print('Three address code of the program:')
		for code in tac:
			print("\t".join(code))
			
	def _allocateReg(self, var):
		"""
			This function allocates a register for a variable.
			Params:
				1. self: the object of this class.
				2. var : type - str; the variable to which register should be allocated. 
		"""
		if var[0] <= "9" and var[0] >= "0":
			return var
		return var
	
	def _threeAddressListify(self):
		"""
			Converts the three address code read to a list of shape (n, 4).
			Every row is a list of order (res, arg1, op, arg2)
		"""
		tac = []
		for code in self.threeAddressCode:
			temp = [x for x in code[:-1].split("\t")]
			while '' in temp:
				temp.remove('')
			tac.append(temp)
		if self.debug: self._printThreeAddress(tac)
		return tac

	def printAssemblyCode(self):
		for line in self.assembly_code:
			print(line)

	def generate(self):
		"""
			This function generates the assembly code for the given program. It doesn't take in any parameters.
			Returns:
				- a list containing all the addresses
		"""
		tac = self._threeAddressListify()
		
		# Iterate through every element of tac. Generate the code.
		for code in tac:
			# An if-else ladder for the "operation" element in the three address code.
			if code[2] == "print":
				line = "print {}".format(self._allocateReg(code[1]))
			elif code[2] in self.binOp.keys():
				line = self.binOp[code[2]]
				line += (" {}, {}, {}".format(self._allocateReg(code[0]), self._allocateReg(code[1]), self._allocateReg(code[3])))
			elif code[2] == "<" or code[2] == ">" or code[2] == ">=" or code[2] == "<=" or code[2] == "==":
				self.assembly_code.append("CMP {}, {}".format(self._allocateReg(code[1]), self._allocateReg(code[3])))
				line = "B{} ".format(self.relOp[code[2]])
			elif code[2] == "=":
				line = "MOV "
				line += "{}, {}".format(self._allocateReg(code[0]), self._allocateReg(code[1]))
			elif code[2] == "IfFalse":
				line = self.assembly_code.pop()
				line += code[0]
			elif code[2] == "Label":
				line = "{}:".format(code[0])
			elif code[2] == "goto":
				line = "B {}".format(code[0])
			else:
				line = ""
			self.assembly_code.append(line)

print("\n\n-----------------------------------CODE GENERATION-----------------------------------\n")
cg = CodeGen('icg', noOfRegs=16)
cg.generate()
cg.printAssemblyCode()