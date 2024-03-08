# 1. clone all release/* branches (starting from 1.2.x) from containerd/containerd repo
# 2. copy docs/ directory in each repo to content/docs/v${MAJOR}.${MINOR}.x
# 3. copy README to content/docs/v${MAJOR}.${MINOR}.x/_index.md
# 4. create an _index.md file in each subdirectory, setting the md title to the directory name, for the nested menu
# 5. clean up

git ls-remote https://github.com/containerd/containerd.git | \
grep --only-matching -E 'release\/.*' | \
while read -r BRANCH ; do \
    REPO_DIR=`echo $BRANCH | tr / -` ; \
    X_VER=`echo $BRANCH | tr -d "release/"` ; \
    # exclude versions 1.0.x and 1.1.x because they have flask syntax that hugo can't render
    if [ $X_VER != "1.0" ] && [ $X_VER != "1.1" ]; then \
        rm -rf $REPO_DIR ; \
        git clone --branch $BRANCH --depth 1 https://github.com/containerd/containerd.git $REPO_DIR ; \
        rm -rf content/docs/v$X_VER.x ; \
        mkdir -p content/docs/v$X_VER.x/docs ; \
        cp -r $REPO_DIR/docs content/docs/v$X_VER.x/ ; \
        # cp $REPO_DIR/README.md content/docs/v$X_VER.x/_index.md ; \
        printf '%s\ntitle: README\n%s\n%s\n%s\n' "---" "---" "$(cat $REPO_DIR/README.md)" > content/docs/v$X_VER.x/_index.md
        find content/docs/v$X_VER.x -type d -execdir bash -c 'name=$0;printf "%s\ntitle: ${name##*/}\n%s\n" "---" "---" > "$name/_index.md";' '{}' \; ; \
        rm -rf $REPO_DIR ; \
    fi ; \
done ;
