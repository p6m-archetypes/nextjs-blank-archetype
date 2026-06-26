let context = #{};

// This generally comes from ANSWERS, but prompting for it ensures it is in the context
context += prompt("Project Author:", "author_full", #{
    placeholder: "Your Name <your.name@example.com>",
});

context += prompt("Org Name:", "org-name", #{
  placeholder: "Acme",
  cased_as: [
    CasedIdentityCasedValue(PROGRAMMING_CASES),
    FixedKeyCasedValue("org-title", TitleCase),
  ],
  help: "Organization Name",
});

context += prompt("Solution Name:", "solution-name", #{
  placeholder: "Platform",
  cased_as: [
    CasedIdentityCasedValue(PROGRAMMING_CASES),
    FixedKeyCasedValue("solution-title", TitleCase),
  ],
  help: "Solution Name",
});

context += set("org-solution-name", render("{{ org-name }}-{{ solution-name }}", context), #{
  cases: [
    CasedIdentityCasedValue(PROGRAMMING_CASES),
  ],
});

context += prompt("Project Prefix:", "prefix-name", #{
  placeholder: "Dashboard",
  cased_as: [
    CasedIdentityCasedValue(PROGRAMMING_CASES),
    FixedKeyCasedValue("project-title", TitleCase),
  ],
  help: "Business Domain/Feature Name",
});

context += prompt("Project Suffix:", "suffix-name", #{
  defaults_with: "ui",
  cased_as: [
    CasedIdentityCasedValue(PROGRAMMING_CASES),
    FixedKeyCasedValue("suffix-title", TitleCase),
  ],
  help: "Project Type (e.g., ui, web, frontend)",
});

context += set("project-name", render("{{ prefix-name }}-{{ suffix-name }}", context), #{
  cases: [
    CasedIdentityCasedValue(PROGRAMMING_CASES),
  ],
});

context += prompt("Application Framework:", "framework", #{
  type: Select(["NextJS"]),
  defaults_with: "NextJS",
  help: "Frontend framework the project is built with",
});

// Framework-specific values used by the Dockerfile/README templates.
// To add a framework: add it to the Select() options above and add an
// `else if context.framework == "<Name>"` branch here that sets the SAME keys.
if context.framework == "NextJS" {
  // README bootstrap command
  context += set("framework-bootstrap", "pnpm create next-app .");
  // Non-root runtime user created in the Dockerfile runner stage
  context += set("runtime-user", "nextjs");
  // Build artifacts copied into the runner stage (Next.js standalone output)
  context += set("framework-build-copy",
    "COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./\n" +
    "COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static");
  // Entry script passed to `node` in the runner stage CMD
  context += set("framework-entrypoint", "server.js");
}

render(Directory("contents/base"), context);

//
// Publishing
//
if switch_enabled("zip") {
  zip(context["project-name"], render("{{ project-name }}.zip", context));
}
if switch_enabled("tarball") {
  tar_gz(context["project-name"], render("{{ project-name }}.tar.gz", context));
}

if switch_enabled("git-init") || switch_enabled("git-publish") {
  git_init(context["project-name"], "main");
  git_add_all(context["project-name"]);
  git_commit(context["project-name"], "initial commit");
  git_remote_add(context["project-name"], "origin", render("https://github.com/{{ org-solution-name }}/{{ project-name }}.git", context));

  if switch_enabled("git-publish") {
    gh_repo_create(render("{{ org-solution-name }}/{{ project-name }}", context), Private);
    git_push(context["project-name"], "origin", "main");
  }
} else {
  display();

  log(Info, "Copy and paste the following commands to publish your project:");

  display();

  display(render("cd {{ project-name }}", context));
  display("git init -b main");
  display(render("gh repo create {{ org-solution-name }}/{{ project-name }} --private --source=. --remote=origin", context));
  display("git add .");
  display("git commit -m 'initial commit'");
  display("git push -u origin HEAD");
}
