
testdir = tests
test_names = $(sort $(wildcard $(testdir)/test_*.scad))

all: test

test:
	for f in $(test_names); do \
		echo -n "$${f}: "; \
		openscad -o /tmp/out.echo --hardwarnings --check-parameters true --check-parameter-ranges false "$${f}" 2>&1 | tee -a /tmp/out.echo ; \
		if [ -s /tmp/out.echo ]; then echo " FAIL: "; \
			cat /tmp/out.echo; \
			rm /tmp/out.echo; \
		else \
			echo " OK"; \
		fi; \
	done


