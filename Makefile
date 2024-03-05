#   Copyright The containerd Authors.

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       http://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

clean:
	rm -rf public resources

# clone all release/* branches from containerd/containerd repo, then
# copy repo docs/ directory in each repo to content/docs/v${MAJOR}.${MINOR}.x
# exclude 1.0.x and 1.1.x docs because they contain flask syntax
refresh-docs:
	git ls-remote https://github.com/containerd/containerd.git | \
	grep --only-matching -E 'release\/.*' | \
	while read -r BRANCH ; do \
    	REPO_DIR=`echo $$BRANCH | tr / -` ; \
    	X_VER=`echo $$BRANCH | tr -d "release/"` ; \
		if [ $$X_VER != 1.0 ] && [ $$X_VER != "1.1" ]; then \
			git clone --branch $$BRANCH --depth 1 https://github.com/containerd/containerd.git $$REPO_DIR ; \
			rm -rf content/v$$X_VER.x ; \
			cp -r $$REPO_DIR/docs content/v$$X_VER.x ; \
			rm -rf $$REPO_DIR ; \
		fi ; \
	done ;

serve: refresh-docs
	hugo server \
		--buildDrafts \
		--buildFuture \
		--disableFastRender

production-build: refresh-docs
	hugo \
	--minify

preview-build: refresh-docs
	hugo \
		--baseURL $(DEPLOY_PRIME_URL) \
		--buildDrafts \
		--buildFuture

install-link-checker:
	curl https://raw.githubusercontent.com/wjdp/htmltest/master/godownloader.sh | bash

run-link-checker:
	bin/htmltest

check-links: clean production-build install-link-checker run-link-checker
