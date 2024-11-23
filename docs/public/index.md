<!---
your comment goes here
and here

gharial documentation master file, created by
   sphinx-quickstart on Mon Oct 10 16:47:09 2022.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.
-->

# Welcome to gharial's documentation!

This is an example documentation, and we want to use MarkDown completely, instead of 
ReStructuredText, hence, all the files are .md and we use the myst-parser.

```{toctree}
---
caption: GitHubActions Experiments
maxdepth: 2
---

basics
stub
stub2
rst_example
image_in_docs
image_in_repo
stub_rst.rst
```

<!---

Note that when we have references, and we need to use, for example :ref:`REFERENCE`
we can use the ```{eval-rst}``` directive, and the whole content within that is
evaluated as if it is RST content.

This is useful for content like this below, which we just want to copy and and reuse from some other RST file.

# Indices and tables
```{eval-rst}

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

```
-->

<!---
Note that references can be simply done via Markdown links as usual, as below.
Note that the [] is empty, so that the link syntax takes the title of the associated document accordingly.
It can be overridden using a specific name here, as in the last item in the list.
-->

# Indices and tables

* [](genindex)
* [](modindex)
* [](search)
* [genindex-custom](genindex)
