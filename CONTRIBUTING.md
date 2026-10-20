# Working agreement

This is how we work. It is the same shape as an engineering team in a real
company, so the habits you build here carry over to your first job.

## 1. The rules

**Allowed**

- Your notes, textbooks and lecture slides.
- Reference docs: [cppreference](https://en.cppreference.com/w/c), `man`
  pages (for example `man 3 printf` in Ubuntu).
- Videos and articles that teach a **concept** ("how does `scanf` handle
  whitespace", "what is a pointer").
- Searching for an **exact error message** from the compiler or valgrind.

**Not allowed**

- AI tools of any kind: ChatGPT, Copilot, Gemini, Claude, AI search
  answers. Keep AI features switched off in your editor.
- Searching for the problem itself ("C program for unit converter").
- Copying code you did not write.

The test is simple: you must be able to explain every line of your PR and
why you wrote it that way. Once a week we pick one of your PRs and you walk
through it.

**When you are stuck**

1. Spend 20 minutes on it yourself. Write down exactly what you do not
   understand.
2. Find the **topic** you are weak in, learn it from the allowed sources,
   then come back to the problem.
3. Still stuck after 45 minutes? Comment on the ticket: what you tried,
   what you expected, what happened. That is a normal, professional thing
   to do.

## 2. The workflow, step by step

Every ticket follows the same loop. The example uses ticket #2.

**Step 1. Start from an up-to-date `main`.**

```
cd ~/code/c-projects && git switch main && git pull
```

**Step 2. Create a branch for the ticket.** The name is
`<type>/<ticket number>-<short-name>`. Types: `feat` (new feature), `fix`
(bug fix), `refactor`, `test`, `docs`.

```
git switch -c feat/2-unit-converter
```

**Step 3. Build in small steps and commit as you go.** A commit is one
logical change that compiles. Aim for 3 to 8 commits per ticket, not one
giant commit at the end.

```
git add projects/002-unit-converter
git commit -m "feat(unit-converter): convert celsius to fahrenheit"
```

Commit message format: `type(scope): what it does now`, lowercase, no full
stop. Good: `fix(unit-converter): reject numbers with trailing letters`.
Bad: `changes`, `final`, `fixed bug`, `asdf`.

**Step 4. Test before you push.**

```
make format && make test P=projects/002-unit-converter
```

Add your own test cases in `tests/`. The examples in the ticket are the
minimum. The reviewer also runs extra hidden tests, so think about edge
cases: empty input, negative numbers, very large numbers, wrong input.

**Step 5. Push the branch.**

```
git push -u origin feat/2-unit-converter
```

**Step 6. Open a pull request** on GitHub. Fill in every section of the
template. The description must contain `Closes #2`, so the ticket closes
when the PR merges. CI checks this.

**Step 7. Wait for CI.** A red cross means something failed. Click
**Details**, read the log, fix it, commit and push again. A PR with red CI
is not ready for review.

**Step 8. Respond to review.** See section 3.

**Step 9. Merge.** Once approved and green, the reviewer merges. Then:

```
git switch main && git pull
```

## 3. Code review

Review is about the code, never about you. Every engineer, including the
most senior ones, gets review comments on every PR.

Comments are labelled:

| Label | Meaning | What you do |
|---|---|---|
| `blocking:` | Must change before merge | Fix it |
| `suggestion:` | Better way, your call | Fix it, or reply with why not |
| `nit:` | Small style point | Fix it, it takes a minute |
| `question:` | Reviewer wants to understand | Answer in a reply |
| `praise:` | Something done well | Nothing, enjoy it |

Rules:

- Reply to **every** comment. After fixing, reply `Done in <commit>`
  (paste the short commit hash).
- Push fixes as **new commits**. Do not rewrite history on a branch under
  review, so the reviewer can see what changed.
- Do not resolve the reviewer's threads yourself. The reviewer resolves a
  thread once satisfied.
- Disagree when you have a reason. "I kept it because X" is a fine reply.

## 4. Project folder rules

- One folder per ticket: `projects/NNN-short-name/`, where NNN is the
  ticket number with leading zeros (ticket 2 becomes `002`).
- Code in `src/`, tests in `tests/`, a short `README.md` with how to run it
  and any decisions you made.
- Never change another project's folder unless the ticket asks you to.
- Copy the shape of [projects/000-example](projects/000-example).

### Writing a test case

A test case is two files with the same name:

- `tests/<name>.in`: what you would type into the program.
- `tests/<name>.out`: exactly what the program must print, character for
  character, including the final newline.

Optional:

- `tests/<name>.code`: the expected exit code, when it is not 0.
- `tests/<name>.args`: command-line arguments, on one line.

Name tests after what they check: `negative-distance.in`, not `test3.in`.

## 5. Definition of done

A ticket is done when **all** of these are true:

- [ ] Every "must" requirement in the ticket works.
- [ ] Your own test cases cover the examples **and** the edge cases.
- [ ] CI is green: it compiles with zero warnings, all tests pass, valgrind
      is clean, and the formatting matches.
- [ ] The PR template is fully filled in, including time spent.
- [ ] Every review comment has a reply.
- [ ] The reviewer has approved and merged.
