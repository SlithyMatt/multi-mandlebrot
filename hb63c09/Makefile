# Define variables
ASM = hb-mand.asm
LIST = hb-mand.lst
OUTPUT = hb-mand.s19

# Define the lwasm command
LZASM = lwasm

# Compilation rule
all: $(OUTPUT)

$(OUTPUT): $(ASM)
	$(LZASM) -l$(LIST) -fsrec -o$(OUTPUT) -3 $(ASM)

# Clean rule
clean:
	rm -f $(LIST) $(OUTPUT)
