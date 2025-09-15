# User Memory

## Gitingest Tool for Repository Analysis

When analyzing Git repositories (especially large codebases), use the gitingest tool to create a comprehensive digest file that saves tokens and provides efficient analysis:

### Basic Usage

```bash
# For local directories
gitingest /path/to/repo -o /tmp/repo_digest.txt

# For GitHub URLs  
gitingest https://github.com/user/repo -o /tmp/repo_digest.txt

# For private repos (with GitHub token)
gitingest https://github.com/user/private-repo -o /tmp/repo_digest.txt -t $GITHUB_TOKEN
```

### Workflow

1. **Create digest**: Run gitingest command to generate a comprehensive text file
2. **Read digest**: Use Read tool to analyze the digest file
3. **Cleanup**: Remove the temporary file when done: `rm /tmp/repo_digest.txt`

### Benefits

- **Token efficient**: Single file contains entire repository structure and content
- **Temporary storage**: Using /tmp/ ensures automatic cleanup on system reboot
- **Comprehensive**: Includes file structure, content, and respects .gitignore patterns
- **Flexible**: Supports local directories and remote GitHub repositories

### Options

- `-s, --max-size`: Limit file size processing (bytes)
- `-e, --exclude-pattern`: Exclude files matching pattern
- `-i, --include-pattern`: Include only files matching pattern
- `--include-gitignored`: Include normally ignored files

## Context7 MCP for Documentation Validation

When making changes to code that involves libraries, frameworks, or APIs, ALWAYS use Context7 MCP to validate against up-to-date documentation before implementing:

### When to Use Context7

- Before implementing new features with external libraries
- When updating existing code that uses third-party dependencies
- Before suggesting API usage patterns or method calls
- When troubleshooting library-specific issues
- When the user asks about best practices for specific frameworks

### Usage Pattern

1. **Before Implementation**: Add "use context7" to your prompt when researching the current documentation
2. **Validation**: Check if your planned implementation matches current API patterns
3. **Implementation**: Proceed with confidence using up-to-date examples

### Example Usage

```
Before implementing authentication with NextAuth.js, let me use context7 to get the latest documentation and ensure I'm using current patterns.
```

### Benefits

- Prevents using deprecated APIs or outdated patterns
- Ensures version-specific accuracy
- Reduces debugging time from outdated examples
- Provides official, current code examples

## Web Search for 2025 Best Practices

Before starting any new implementation, ALWAYS web search for current best practices and 2025 patterns:

### When to Web Search

- Before implementing any new feature or component
- When choosing between multiple architectural approaches
- Before selecting libraries, frameworks, or tools
- When implementing security-sensitive functionality
- Before performance optimization strategies

### Search Strategy

1. **Current Year Focus**: Include "2025" in search queries to get latest practices
2. **Best Practices**: Search for "best practices 2025" for the specific technology
3. **Security Considerations**: Always check for current security recommendations
4. **Performance Patterns**: Look for modern performance optimization techniques

### Benefits

- Ensures implementation follows current industry standards
- Incorporates latest security practices
- Leverages modern performance optimizations
- Avoids deprecated or discouraged patterns

