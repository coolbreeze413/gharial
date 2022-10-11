# Documentation

This doc will cover documentation concepts.

We have a few options to use, for a neat set of documentation for any project.  
Note that we talk about a cohesive, structured **set** of documentation, rather than a loose group of doc files.  
We will only focus on Github, but most options should be usable for any other repos as applicable.  

- Github Pages : simplest, self contained, flexible and useful for **public** github repos
- Sphinx + ReadTheDocs : use sphinx for generating the documentation set, and ReadTheDocs(RTD) for hosting/theming/auto-build
- Mkdocs + ReadTheDocs : use Mkdocs for generating documentation set, and RTD for hosting/theming/auto-build

For a simpler use case, with only Markdown files, Mkdocs can be used, and is also supported by ReadTheDocs.
However, Sphinx now has proper support for Markdown files, with the MyST parser, and hence will be our choice.

Sphinx is pretty powerful, flexible and popular, hence will have the most amount of help (and that may be confusing at times as well!).
Recently, Sphinx has support for the MyST-Parser, which brings in full support for Markdown, in place of RestructuredText only.
As we would like to keep the documentation common between Github and Documentation set in sphinx, we can either:
- use RST all through, as Github renders RST fine as well.
- use MD all through, and Sphinx can re-use these files.

It is a subjective choice, and if there is more comfort in MD, or RST, that should be the choice.
Note that, either way, there can be mixed content, so it need to be a hard and fast choice, however: it is recommended to keep all the docs in a single format to avoid confusion!
For us, Markdown looks like a better choice for now, as it is simpler to write content, and is also the default format for Github doc files.

So, we will look at Sphinx + MyST-parser + ReadTheDocs, and:
- all docs are markdown docs
- Sphinx is used for building the documentation
- ReadTheDocs is used for hosting the documentation, and auto-builds etc.

## Sphinx Setup

We need a few pre-requisites for sphinx, to be able to build the documentation and view it locally.

- python needs to be installed : 3.7+ preferably.
- python modules needed :  
  - `myst-parser` (it will automatically install sphinx and other dependencies as well)
  - `sphinx-rtd-theme` so that we can actually see how it will look on readthedocs after hosting


## Sphinx Configuration

Sphinx configuration is controlled with the `conf.py` file.

- navigate to the root of the documentation directory, where we want the index, and all docs to exist.
- execute `sphinx-quickstart`
- this will prompt for a few answers, w.r.t project name, author etc., default options on most is ok.
- this will generate a `conf.py` file, and that can be further modified as needed:
  - `extensions = ["myst_parser"]` should be set (or added to list of extensions)  
  - `html_theme = 'sphinx_rtd_theme'` should be set  
- by default, sphinx will create a `index.rst` file in the root of the documentation directory  
  we can change this to be `index.md`, refer to the file in this repo: `docs/public/index.md`  
  NOTE: this conversion can also done using the `rst2myst` utility, as specified here: [Migrate From RST to MD](https://docs.readthedocs.io/en/stable/guides/migrate-rest-myst.html#how-to-convert-existing-restructuredtext-documentation-to-myst)

Now, we are ready to build the documentation and add content.

## sphinx build

sphinx generates a Makefile to make it simpler to use.

- execute `make html` from the documentation directory, or `sphinx-build -M html "<documentation_directory>" "<documentation_directory>/_build"` if you have no make support.
  
  If you have chosen default options, there will be a `_build/html` directory in the documentation root directory, and we can open the `index.html` in any browser to view the documentation.

## Sphinx content

This section will talk about adding content and doc files in different scenarios to the Sphinx documentation set.

### simple markdown or rst file in documentation directory
- create any markdown or rst file in the documentation directory
- add to the index.md in the toctree, with relative path from the documenation directory (extension .md/.rst is optional)

### markdown file from outside the documentation directory (somewhere in the repo)
- create a 'stub' markdown file in the documentation directory with any name, say `stub_filewewanttoinclude.md`
- add only an `include` directive with the path to the file, relative to the documentation directory, like so
  ```
  ```{include} ../docs.md
  ```
- then add the 'stub' markdown file into the index.md toctree, and the whole content of the actual file should show up.

### rst file from outside the documentation directory (somewhere in the repo)
- same as for md, but with a 'stub' rst file. (don't mix content unless absoutely required)

### using rst content in markdown files

myst-parser provides the `eval-rst` to include rst content into markdown files.
```
    # Indices and tables
    ```{eval-rst}

    * :ref:`genindex` this is rst content
    * :ref:`modindex`
    * :ref:`search`

    ```
```

The part within the `eval-rst` directive will be parsed using native sphinx rst parsing.


## RTD setup

Reference: https://docs.readthedocs.io/en/stable/config-file/index.html

Basically, we need a `.readthedocs.yaml` file in the root of the repo, and a `requirements.txt` file for the python package dependencies, which can be placed anywhere, recommended to keep it in the documentation root directory, so it is clear that this is meant for documentation build requirements.

The `.readthedocs.yaml` contains the build env details we want to use, the python configuration and path to `requirements.txt` for installation of the required packages, and the path to the sphinx configuration file `conf.py`.

All paths are relative to the root of the repo.

There are quite a few other configuration options, and can be found here: https://docs.readthedocs.io/en/stable/config-file/v2.html

## RTD Enable Doc Build

- Login to RTD: refer [Choosing RTD Platform](https://docs.readthedocs.io/en/stable/choosing-a-site.html)
  - Use [RTD Community](https://readthedocs.org/) for open source docs (public github repos)
  - Use [RTD Business](https://readthedocs.com/) for closed source docs (private github repos)

- Import Project:
  - select Import a Project, and Manually add by providing the repo details, or select from repo list (if Github account is connected to the ReadTheDocs account already)
    
    Refer to this for connecting Github Account to RTD: https://docs.readthedocs.io/en/latest/connected-accounts.html

- Build Docs:
  - Now that the project is imported, we can build the docs at anytime with the project link from RTD

- Integration
  - Integration with RTD enables RTD to autobuild documentation on push events etc.
  - If the Github Account is connected to RTD, the integration should be setup automatically
  - If not, then a webhook can be setup manually
  - reference: https://docs.readthedocs.io/en/latest/integrations.html#integration-creation

That's it, we should now be ready with automated documentation builds.
Add another line.
