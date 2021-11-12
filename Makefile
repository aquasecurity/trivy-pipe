.PHONY: tagger
tagger:
	@git checkout main
	@git fetch --tags
	@echo "the most recent tag was `git describe --tags --abbrev=0`"
	@echo ""
	read -p "Tag number: " TAG; \
	 git tag -a "$${TAG}" -m "$${TAG}"; \
	 git push origin "$${TAG}"