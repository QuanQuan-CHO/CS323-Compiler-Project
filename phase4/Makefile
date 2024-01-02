splc: splc.py
	pyinstaller --log-level WARN --distpath bin -F splc.py

.PHONY: test clean
test: splc test/test.py
	cd test && python3 test.py
clean:
	@rm -rf __pycache__ build bin splc.spec test/*.s
