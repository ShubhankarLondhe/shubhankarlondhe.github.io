# shubhankarlondhe.github.io

Personal academic website of Shubhankar Londhe, built with Jekyll and the [al-folio](https://github.com/alshedivat/al-folio) theme. Live at <https://shubhankarlondhe.github.io>.

Pushing to `main` triggers the `Deploy site` GitHub Action, which builds the site into the `gh-pages` branch.

## Where to edit content

| What | File |
| --- | --- |
| Bio, profile picture caption | `_pages/about.md` |
| Publications | `_bibliography/papers.bib` (`selected={true}` shows a paper on the home page) |
| Code / project cards | `_data/repositories.yml` |
| CV (education, talks, awards) | `_data/cv.yml` |
| Social links | `_data/socials.yml` |
| Teaching | `_pages/teaching.md` |
| Site settings | `_config.yml` |

## Local preview

```bash
docker compose up
```

Then open <http://localhost:8080>.
