NAME    := sleepyzpool

.DEFAULT_GOAL := packages

REVISION := $(shell git rev-list --count HEAD)
COMMIT   := $(shell git describe --always --abbrev --match '^$$')
VERSION  := r$(REVISION)-g$(COMMIT)

# ---------- install ----------

# installation directory
DESTDIR :=

# install script and config
.PHONY: install
install : \
	$(DESTDIR)/usr/bin/$(NAME) \
	$(DESTDIR)/etc/$(NAME).toml \
	$(DESTDIR)/usr/lib/systemd/system/$(NAME).service

$(DESTDIR)/usr/bin/$(NAME): $(NAME)
	install -m 755 -D $< $@

$(DESTDIR)/etc/$(NAME).toml: $(NAME).toml
	install -m 644 -D $< $@

$(DESTDIR)/usr/lib/systemd/system/$(NAME).service: $(NAME).service
	install -m 644 -D $< $@

# ---------- package ----------

# package metadata
PKGNAME     = $(NAME)
PKGURL      = https://github.com/ansemjo/sleepyzpool
PKGVERSION  = $(shell echo $(VERSION) | sed s/-/./ )
PKGFORMATS  = rpm deb apk
PKGARCH     = $(shell uname -m)

# how to execute fpm
FPM = docker run --rm --net none -v $$PWD:/src -w /src ghcr.io/ansemjo/fpm

# build a package
.PHONY: package-%
package-% :
	make --no-print-directory install DESTDIR=package
	mkdir -p release
	$(FPM) -s dir -t $* -f --chdir package \
		--name $(PKGNAME) \
		--version v0.$(REVISION).g$(COMMIT) \
		--url $(PKGURL) \
		--package release/$(PKGNAME)-$(VERSION).$*

# build all package formats with fpm
.PHONY: packages
packages : $(addprefix package-,$(PKGFORMATS))
