class CodeGen:
	def __init__(self, pathICG, pathST, noOfRegs, debug=False):
		"""
			The constructor function for the class that generates assembly level code.
			Input params:
				1. self: the object of the class
				2. pathICG: path to the file which contains the final Intermediate Code (IC)
				3. pathST : path to the file which contains the variables used in the program
				4. noOfRegs: the number of registers available for execution of the program
				5. debug: parameter which will output information during running, if True. Initialised to False.
		"""
		f = open(pathICG)
		self.threeAddressCode = f.readlines()
		s = open(pathST)
		self.st = s.readlines()
		f.close()
		s.close()
		self.noOfRegs = noOfRegs
		self.aliveVars = []
		self.debug = debug
		self._regInit()
		self.binOp = {
			'+': "ADD",
			'-': "SUB",
			"*": "MUL",
			"/": "DIV"
		}
		# Storing the opposites of the required relational operation as IfFalse is used in ICG.
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
		if self.debug: self._printList(tac, "Printing the three address codes")
		return tac

	def _findStart(self, var):
		"""
			Finds the starting line number for a variable
			Params:
				1. self : the class object 
				2. var  : the variable for which the starting point has to be found
		"""
		for i in range(len(self.threeAddressCode)):
			if var in self.threeAddressCode[i]:
				return i

	def _findEnd(self, var):
		"""
			Finds the starting line number for a variable
			Params:
				1. self : the class object 
				2. var  : the variable for which the ending point has to be found
		"""
		for i in range(len(self.threeAddressCode) - 1, -1, -1):
			if var in self.threeAddressCode[i]:
				return i

	def _findAliveIntervals(self):
		"""
			This function returns a structure which contains the interval in which every variable is active.
		"""
		self.intervals = {}
		for var in self.st:
			start = self._findStart(var[0])
			if start is not None:
				end = self._findEnd(var[0])
				self.intervals[var[0]] = [start, end]
		if self.debug: self._printList(self.intervals, "Printing the intervals of different variables")
	
	def _printList(self, l, header=None):
		"""
			A function to print the three address code.
			Params:
				1. Any iterable
				2. header: a text to print before printing the list passed. Defaulted to None.
		"""
		if header: print(header)
		if type(l) == dict:
			for key in l:
				print("{}: {}".format(key, l[key]))
		else:
			for code in l:
				if type(code) == str:
					print(code)
				else:
					print("\t".join(code))
		print("\n\n")

	def _aliveVars(self, lineno):
		"""
			This function returns a list of the alive variables at the current point.
			Params:
				1. self   : object of the class
				2. lineno : line number (or index) of the TAC structure.
		"""
		for var in self.intervals:
			if var in self.aliveVars and self.intervals[var][1] < lineno:
				self.aliveVars.remove(var)
			if var not in self.aliveVars and self.intervals[var][0] == lineno:
				self.aliveVars.append(var)

	def _freeReg(self):
		"""
			Deallocates any registers which are holding variables currently not alive
		"""
		for key in self.regState.keys():
			if self.regState[key] and self.regState[key] not in self.aliveVars:
				self.assembly_code.append("ST {}, {}".format(self.regState[key], key))
				self.regState[key] = None
			
	def _allocateReg(self, var, lineno):
		"""
			This function allocates a register for a variable.
			Params:
				1. self   : the object of this class.
				2. var    : type - str; the variable to which register should be allocated.
				3. lineno : the current line number
		"""
		self._aliveVars(lineno)
		self._freeReg()
		if var[0] <= "9" and var[0] >= "0":
			return "#" + var
		# if variable is in self.regState.values(), 
		# it means that the variable is already allocated a register and we simply need to find it
		if var in self.regState.values():
			for reg in self.regState:
				if self.regState[reg] == var:
					return reg
		else:
			for reg in self.regState:
				if self.regState[reg] is None:
					self.assembly_code.append("LD {}, {}".format(reg, var))
					self.regState[reg] = var
					return reg

	def _symbolTableListify(self):
		"""
			Returns a list which contains all the variables used in the program
		"""
		st = []
		for line in self.st:
			st.append(line[:-1].split("\t"))
		if self.debug: self._printList(st, "Printing the symbols")
		return st

	def printAssemblyCode(self):
		"""
			prints the generated assembly code.
		"""
		for line in self.assembly_code:
			print(line)

	def generate(self):
		"""
			This function generates the assembly code for the given program. It doesn't take in any parameters.
		"""
		self.st = self._symbolTableListify()
		self.threeAddressCode = self._threeAddressListify()
		self._findAliveIntervals()

		# Iterate through every element of tac. Generate the code.
		for lineno in range(len(self.threeAddressCode)):
			code = self.threeAddressCode[lineno]
			# An if-else ladder for the "operation" element in the three address code.
			if code[2] == "print":
				line = "print {}".format(self._allocateReg(code[1], lineno))

			# If the current line performs a binary operation
			elif code[2] in self.binOp.keys():
				line = self.binOp[code[2]]
				line += (" {}, {}, {}".format(self._allocateReg(code[0], lineno), self._allocateReg(code[1], lineno), self._allocateReg(code[3], lineno)))
			# If the current line performs a relational operation
			elif code[2] in self.relOp.keys():
				self.assembly_code.append("CMP {}, {}".format(self._allocateReg(code[1], lineno), self._allocateReg(code[3], lineno)))
				line = "B{} ".format(self.relOp[code[2]])
			elif code[2] == "=":
				line = "MOV "
				line += "{}, {}".format(self._allocateReg(code[0], lineno), self._allocateReg(code[1], lineno))
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
		self._aliveVars(len(self.threeAddressCode) + 1)
		self._freeReg()

print("\n\n-----------------------------------CODE GENERATION-----------------------------------\n")
cg = CodeGen('icg', 'st', noOfRegs=4)
cg.generate()
cg.printAssemblyCode()