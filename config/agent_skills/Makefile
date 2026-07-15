claude/install-all:
	$(MAKE) claude/install/handlename/agent-skills:3d269dfef1b9273a444696f3dbe59ec2a0876e4f
	$(MAKE) claude/install/yeachan-heo/oh-my-claudecode:v4.15.4
	$(MAKE) claude/install/modem-dev/hunk:v0.17.0

claude/install/%:
	$(MAKE) install/$* AGENT=claude

antigravity/install-all:
	$(MAKE) antigravity/install/handlename/agent-skills:3d269dfef1b9273a444696f3dbe59ec2a0876e4f
	$(MAKE) antigravity/install/obra/superpowers:v6.1.1
	$(MAKE) antigravity/install/modem-dev/hunk:v0.17.0

antigravity/install/%:
	$(MAKE) install/$* AGENT=gemini-cli

install/%:
	target=$*; \
	repo=$(word 1, $(subst :, ,$*)); \
	version=$(word 2, $(subst :, ,$*)); \
	gh skill install "$$repo" \
	    --pin "$$version" \
	    --scope user \
	    --agent "$(AGENT)" \
	    --all \
	    --force
