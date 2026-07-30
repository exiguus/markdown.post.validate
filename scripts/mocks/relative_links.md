+++
title = "Test Relative Links"
description = "A post with relative links that should not cause A3 failures"
date = 2026-07-29
authors = ["test"]
[taxonomies]
tags = ["test", "links", "relative"]
+++

## Introduction

This post has relative links that should be ignored by lychee.

## Content

Here are some relative links:

- [Relative with @/](@/posts/some-post/index.md)
- [Relative with ./](./some-file.md)
- [Relative with ../](../parent/file.md)
- [Root relative](/absolute/path.md)

## Conclusion

These links should not cause A3 dead link failures.
