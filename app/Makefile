SUBDIRS = fir_micpro tstor tstbitat0

.PHONY: subdirs $(SUBDIRS)

subdirs: $(SUBDIRS)

$(SUBDIRS):
	@echo "Making $@"
	$(MAKE) -C $@

clean: 
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done

