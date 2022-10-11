# Stub 2

Here we have some content, and then we include another md file with its contents. Will it work?

YES, but it adds another separate TOPIC as well extra???
That's bad, but as expected, because, the `include` directive just copies the doc verbatim and pastes the content at the place of the directive
The TOCTREE considers TITLE (#) as topic, and (##) as subtopic, so as we have # Stub2, and # Documentation, both will appear in the toctree.

So, we have 2 options:
- use the doc as is, and only have a simple stub with nothing but ````{include} path/to/actual/document`
- ensure that the doc being included does not have a top-level title with (#) and then we can have content in the stub, as well as content from the included doc!

## Stub 2 Content is Here

This is the stub 2 content

<!--- This one is not good:
```{include} ../docs.md
```
-->
```{include} ../stub2_content.md
```

## Stub 2 Content 2 is Here

This is the stub 2 content 2