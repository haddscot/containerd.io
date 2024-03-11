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
        # copy README into v$X_VER.x/_index.md with a title added
        printf '%s\ntitle: README\n%s\n%s\n%s\n' "---" "---" "$(cat $REPO_DIR/README.md)" > content/docs/v$X_VER.x/_index.md
        # create titled _index.md files in all subdirs so that hugo sees them as "sections" --
        # this is required for nested-menu-partial to behave correctly
        find content/docs/v$X_VER.x -type d -execdir bash -c 'name=$0;printf "%s\ntitle: ${name##*/}\n%s\n" "---" "---" > "$name/_index.md";' '{}' \; ; \
        # copy images to static/ since they can't be read from content/
        rsync --remove-source-files --files-from <(find content/docs/v$X_VER.x -type f -exec file --mime-type {} \+ | awk -F: '{if ($2 ~/image\//) print $1}') . "static/"
        rm -rf $REPO_DIR ; \
    fi ; \
done ;
# move images from static/content/docs/v$X_VER.x/... to static/docs/v$X_VER.x/... so that docs find them where they expect to see them
rm -rf static/docs
mv static/content/* static/
