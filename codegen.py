class CodeGen:
	def __init__(self, path, debug=False):
		self.path = path
		f = open(path)
		self.threeAddressCode = f.readlines()
		self.debug = debug
		if self.debug: print(self.threeAddressCode)

	def generate(self):
		pass

cg = CodeGen('icg', debug=True)