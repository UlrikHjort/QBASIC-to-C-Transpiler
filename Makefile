CC = gcc
CFLAGS = -Wall -g
FLEX = flex
BISON = bison

SRCDIR = src
BINDIR = bin
OUTPUTDIR = output
TESTDIR = tests
BUILDDIR = build

# Create directories if they don't exist
$(shell mkdir -p $(BINDIR) $(OUTPUTDIR) $(BUILDDIR))

all: $(BINDIR)/qb2c

$(BINDIR)/qb2c: $(BUILDDIR)/qb2c.tab.o $(BUILDDIR)/lex.yy.o
	$(CC) $(CFLAGS) -o $@ $^ -lm

$(BUILDDIR)/qb2c.tab.c $(BUILDDIR)/qb2c.tab.h: $(SRCDIR)/qb2c.y
	$(BISON) -d -o $(BUILDDIR)/qb2c.tab.c $(SRCDIR)/qb2c.y

$(BUILDDIR)/lex.yy.c: $(SRCDIR)/qb2c.l $(BUILDDIR)/qb2c.tab.h
	$(FLEX) -o $(BUILDDIR)/lex.yy.c $(SRCDIR)/qb2c.l

$(BUILDDIR)/qb2c.tab.o: $(BUILDDIR)/qb2c.tab.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILDDIR)/lex.yy.o: $(BUILDDIR)/lex.yy.c
	$(CC) $(CFLAGS) -c -o $@ $<

clean:
	rm -rf $(BINDIR) $(BUILDDIR) $(OUTPUTDIR)
	mkdir -p $(BINDIR) $(OUTPUTDIR) $(BUILDDIR)

test: $(BINDIR)/qb2c
	@echo "=== Testing basic.bas ==="
	$(BINDIR)/qb2c $(TESTDIR)/test.bas $(OUTPUTDIR)/test.c
	$(CC) -o $(OUTPUTDIR)/test_program $(OUTPUTDIR)/test.c -lm
	@echo "5" | $(OUTPUTDIR)/test_program

test-all: $(BINDIR)/qb2c
	@for bas_file in $(TESTDIR)/*.bas; do \
		echo "=== Testing $$bas_file ==="; \
		base=$$(basename $$bas_file .bas); \
		$(BINDIR)/qb2c $$bas_file $(OUTPUTDIR)/$$base.c || exit 1; \
		$(CC) -o $(OUTPUTDIR)/$$base $(OUTPUTDIR)/$$base.c -lm || exit 1; \
		echo "Compiled $$base successfully"; \
	done

.PHONY: all clean test test-all
