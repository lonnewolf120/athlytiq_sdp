#!/usr/bin/env node
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { CallToolRequestSchema, ListToolsRequestSchema, ToolSchema, } from "@modelcontextprotocol/sdk/types.js";
import fs from "fs/promises";
import path from "path";
import os from 'os';
import { z } from "zod";
import { zodToJsonSchema } from "zod-to-json-schema";
import { createTwoFilesPatch } from 'diff';
import { minimatch } from 'minimatch';
// Command line argument parsing
const args = process.argv.slice(2);
if (args.length === 0) {
    console.error("Usage: mcp-server-filesystem [additional-directories...]");
    process.exit(1);
}
// Normalize all paths consistently
function normalizePath(p) {
    return path.normalize(p);
}
function expandHome(filepath) {
    if (filepath.startsWith('~/') || filepath === '~') {
        return path.join(os.homedir(), filepath.slice(1));
    }
    return filepath;
}
// Store allowed directories in normalized form
const allowedDirectories = args.map(dir => normalizePath(path.resolve(expandHome(dir))));
// Validate that all directories exist and are accessible
await Promise.all(args.map(async (dir) => {
    try {
        const stats = await fs.stat(expandHome(dir));
        if (!stats.isDirectory()) {
            console.error(`Error: ${dir} is not a directory`);
            process.exit(1);
        }
    }
    catch (error) {
        console.error(`Error accessing directory ${dir}:`, error);
        process.exit(1);
    }
}));
// Security utilities
async function validatePath(requestedPath) {
    const expandedPath = expandHome(requestedPath);
    const absolute = path.isAbsolute(expandedPath) ? path.resolve(expandedPath) : path.resolve(process.cwd(), expandedPath);
    const normalizedRequested = normalizePath(absolute);
    // Check if path is within allowed directories
    const isAllowed = allowedDirectories.some(dir => normalizedRequested.startsWith(dir));
    if (!isAllowed) {
        throw new Error(`Access denied - path outside allowed directories: ${absolute} not in ${allowedDirectories.join(', ')}`);
    }
    // Handle symlinks by checking their real path
    try {
        const realPath = await fs.realpath(absolute);
        const normalizedReal = normalizePath(realPath);
        const isRealPathAllowed = allowedDirectories.some(dir => normalizedReal.startsWith(dir));
        if (!isRealPathAllowed) {
            throw new Error("Access denied - symlink target outside allowed directories");
        }
        return realPath;
    }
    catch (error) {
        // For new files that don't exist yet, verify parent directory
        const parentDir = path.dirname(absolute);
        try {
            const realParentPath = await fs.realpath(parentDir);
            const normalizedParent = normalizePath(realParentPath);
            const isParentAllowed = allowedDirectories.some(dir => normalizedParent.startsWith(dir));
            if (!isParentAllowed) {
                throw new Error("Access denied - parent directory outside allowed directories");
            }
            return absolute;
        }
        catch {
            throw new Error(`Parent directory does not exist: ${parentDir}`);
        }
    }
}
// Schema definitions
const ReadFileArgsSchema = z.object({
    path: z.string(),
    tail: z.number().optional().describe('If provided, returns only the last N lines of the file'),
    head: z.number().optional().describe('If provided, returns only the first N lines of the file')
});
const ReadMultipleFilesArgsSchema = z.object({
    paths: z.array(z.string()),
});
const WriteFileArgsSchema = z.object({
    path: z.string(),
    content: z.string(),
});
const EditOperation = z.object({
    oldText: z.string().describe('Text to search for - must match exactly'),
    newText: z.string().describe('Text to replace with')
});
const EditFileArgsSchema = z.object({
    path: z.string(),
    edits: z.array(EditOperation),
    dryRun: z.boolean().default(false).describe('Preview changes using git-style diff format')
});
const CreateDirectoryArgsSchema = z.object({
    path: z.string(),
});
const ListDirectoryArgsSchema = z.object({
    path: z.string(),
});
const ListDirectoryWithSizesArgsSchema = z.object({
    path: z.string(),
    sortBy: z.enum(['name', 'size']).optional().default('name').describe('Sort entries by name or size'),
});
const DirectoryTreeArgsSchema = z.object({
    path: z.string(),
});
const MoveFileArgsSchema = z.object({
    source: z.string(),
    destination: z.string(),
});
const SearchFilesArgsSchema = z.object({
    path: z.string(),
    pattern: z.string(),
    excludePatterns: z.array(z.string()).optional().default([])
});
const GetFileInfoArgsSchema = z.object({
    path: z.string(),
});
const ToolInputSchema = ToolSchema.shape.inputSchema;
// Server setup
const server = new Server({
    name: "secure-filesystem-server",
    version: "0.2.0",
}, {
    capabilities: {
        tools: {},
    },
});
// Tool implementations
async function getFileStats(filePath) {
    const stats = await fs.stat(filePath);
    return {
        size: stats.size,
        created: stats.birthtime,
        modified: stats.mtime,
        accessed: stats.atime,
        isDirectory: stats.isDirectory(),
        isFile: stats.isFile(),
        permissions: stats.mode.toString(8).slice(-3),
    };
}
async function searchFiles(rootPath, pattern, excludePatterns = []) {
    const results = [];
    async function search(currentPath) {
        const entries = await fs.readdir(currentPath, { withFileTypes: true });
        for (const entry of entries) {
            const fullPath = path.join(currentPath, entry.name);
            try {
                // Validate each path before processing
                await validatePath(fullPath);
                // Check if path matches any exclude pattern
                const relativePath = path.relative(rootPath, fullPath);
                const shouldExclude = excludePatterns.some(pattern => {
                    const globPattern = pattern.includes('*') ? pattern : `**/${pattern}/**`;
                    return minimatch(relativePath, globPattern, { dot: true });
                });
                if (shouldExclude) {
                    continue;
                }
                if (entry.name.toLowerCase().includes(pattern.toLowerCase())) {
                    results.push(fullPath);
                }
                if (entry.isDirectory()) {
                    await search(fullPath);
                }
            }
            catch (error) {
                // Skip invalid paths during search
                continue;
            }
        }
    }
    await search(rootPath);
    return results;
}
// file editing and diffing utilities
function normalizeLineEndings(text) {
    return text.replace(/\r\n/g, '\n');
}
function createUnifiedDiff(originalContent, newContent, filepath = 'file') {
    // Ensure consistent line endings for diff
    const normalizedOriginal = normalizeLineEndings(originalContent);
    const normalizedNew = normalizeLineEndings(newContent);
    return createTwoFilesPatch(filepath, filepath, normalizedOriginal, normalizedNew, 'original', 'modified');
}
async function applyFileEdits(filePath, edits, dryRun = false) {
    // Read file content and normalize line endings
    const content = normalizeLineEndings(await fs.readFile(filePath, 'utf-8'));
    // Apply edits sequentially
    let modifiedContent = content;
    for (const edit of edits) {
        const normalizedOld = normalizeLineEndings(edit.oldText);
        const normalizedNew = normalizeLineEndings(edit.newText);
        // If exact match exists, use it
        if (modifiedContent.includes(normalizedOld)) {
            modifiedContent = modifiedContent.replace(normalizedOld, normalizedNew);
            continue;
        }
        // Otherwise, try line-by-line matching with flexibility for whitespace
        const oldLines = normalizedOld.split('\n');
        const contentLines = modifiedContent.split('\n');
        let matchFound = false;
        for (let i = 0; i <= contentLines.length - oldLines.length; i++) {
            const potentialMatch = contentLines.slice(i, i + oldLines.length);
            // Compare lines with normalized whitespace
            const isMatch = oldLines.every((oldLine, j) => {
                const contentLine = potentialMatch[j];
                return oldLine.trim() === contentLine.trim();
            });
            if (isMatch) {
                // Preserve original indentation of first line
                const originalIndent = contentLines[i].match(/^\s*/)?.[0] || '';
                const newLines = normalizedNew.split('\n').map((line, j) => {
                    if (j === 0)
                        return originalIndent + line.trimStart();
                    // For subsequent lines, try to preserve relative indentation
                    const oldIndent = oldLines[j]?.match(/^\s*/)?.[0] || '';
                    const newIndent = line.match(/^\s*/)?.[0] || '';
                    if (oldIndent && newIndent) {
                        const relativeIndent = newIndent.length - oldIndent.length;
                        return originalIndent + ' '.repeat(Math.max(0, relativeIndent)) + line.trimStart();
                    }
                    return line;
                });
                contentLines.splice(i, oldLines.length, ...newLines);
                modifiedContent = contentLines.join('\n');
                matchFound = true;
                break;
            }
        }
        if (!matchFound) {
            throw new Error(`Could not find exact match for edit:\n${edit.oldText}`);
        }
    }
    // Create unified diff
    const diff = createUnifiedDiff(content, modifiedContent, filePath);
    // Format diff with appropriate number of backticks
    let numBackticks = 3;
    while (diff.includes('`'.repeat(numBackticks))) {
        numBackticks++;
    }
    const formattedDiff = `${'`'.repeat(numBackticks)}diff\n${diff}${'`'.repeat(numBackticks)}\n\n`;
    if (!dryRun) {
        await fs.writeFile(filePath, modifiedContent, 'utf-8');
    }
    return formattedDiff;
}
// Helper functions
function formatSize(bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes === 0)
        return '0 B';
    const i = Math.floor(Math.log(bytes) / Math.log(1024));
    if (i === 0)
        return `${bytes} ${units[i]}`;
    return `${(bytes / Math.pow(1024, i)).toFixed(2)} ${units[i]}`;
}
// Memory-efficient implementation to get the last N lines of a file
async function tailFile(filePath, numLines) {
    const CHUNK_SIZE = 1024; // Read 1KB at a time
    const stats = await fs.stat(filePath);
    const fileSize = stats.size;
    if (fileSize === 0)
        return '';
    // Open file for reading
    const fileHandle = await fs.open(filePath, 'r');
    try {
        const lines = [];
        let position = fileSize;
        let chunk = Buffer.alloc(CHUNK_SIZE);
        let linesFound = 0;
        let remainingText = '';
        // Read chunks from the end of the file until we have enough lines
        while (position > 0 && linesFound < numLines) {
            const size = Math.min(CHUNK_SIZE, position);
            position -= size;
            const { bytesRead } = await fileHandle.read(chunk, 0, size, position);
            const text = chunk.toString('utf8', 0, bytesRead);
            // Prepend to remainingText to maintain correct order
            remainingText = text + remainingText;
            // Count newlines in the current chunk
            let newlineCount = (text.match(/\n/g) || []).length;
            linesFound += newlineCount;
            // If we have more lines than needed, trim from the beginning
            if (linesFound >= numLines) {
                const excessLines = linesFound - numLines;
                const firstNewlineIndex = nthIndex(remainingText, '\n', excessLines);
                if (firstNewlineIndex !== -1) {
                    remainingText = remainingText.substring(firstNewlineIndex + 1);
                }
                linesFound = numLines; // Cap linesFound
            }
        }
        // Ensure we don't return more than numLines
        const finalLines = remainingText.split('\n');
        if (finalLines.length > numLines) {
            return finalLines.slice(finalLines.length - numLines).join('\n');
        }
        return remainingText;
    }
    finally {
        await fileHandle.close();
    }
}
// Helper to find the nth occurrence of a character
function nthIndex(str, pat, n) {
    let i = -1;
    while (n-- && i++ < str.length) {
        i = str.indexOf(pat, i);
        if (i < 0)
            break;
    }
    return i;
}
// Memory-efficient implementation to get the first N lines of a file
async function headFile(filePath, numLines) {
    const CHUNK_SIZE = 1024; // Read 1KB at a time
    const fileHandle = await fs.open(filePath, 'r');
    try {
        let linesRead = 0;
        let buffer = '';
        let bytesRead;
        const chunk = Buffer.alloc(CHUNK_SIZE);
        while (linesRead < numLines && (bytesRead = await fileHandle.read(chunk, 0, CHUNK_SIZE, null)).bytesRead > 0) {
            buffer += chunk.toString('utf8', 0, bytesRead.bytesRead);
            const newlines = (buffer.match(/\n/g) || []).length;
            linesRead += newlines;
            if (linesRead >= numLines) {
                const lines = buffer.split('\n');
                return lines.slice(0, numLines).join('\n');
            }
        }
        return buffer;
    }
    finally {
        await fileHandle.close();
    }
}
// Tool definitions
const tools = [
    {
        name: 'read_file',
        description: 'Read complete contents of a file',
        inputSchema: zodToJsonSchema(ReadFileArgsSchema),
    },
    {
        name: 'read_multiple_files',
        description: 'Read multiple files simultaneously',
        inputSchema: zodToJsonSchema(ReadMultipleFilesArgsSchema),
    },
    {
        name: 'write_file',
        description: 'Create new file or overwrite existing (exercise caution with this)',
        inputSchema: zodToJsonSchema(WriteFileArgsSchema),
    },
    {
        name: 'edit_file',
        description: 'Make selective edits using advanced pattern matching and formatting',
        inputSchema: zodToJsonSchema(EditFileArgsSchema),
    },
    {
        name: 'create_directory',
        description: 'Create new directory or ensure it exists',
        inputSchema: zodToJsonSchema(CreateDirectoryArgsSchema),
    },
    {
        name: 'list_directory',
        description: 'List directory contents with [FILE] or [DIR] prefixes',
        inputSchema: zodToJsonSchema(ListDirectoryArgsSchema),
    },
    {
        name: 'list_directory_with_sizes',
        description: 'List directory contents with sizes, sorted by name or size',
        inputSchema: zodToJsonSchema(ListDirectoryWithSizesArgsSchema),
    },
    {
        name: 'directory_tree',
        description: 'List directory contents as a tree structure',
        inputSchema: zodToJsonSchema(DirectoryTreeArgsSchema),
    },
    {
        name: 'move_file',
        description: 'Move or rename files and directories',
        inputSchema: zodToJsonSchema(MoveFileArgsSchema),
    },
    {
        name: 'search_files',
        description: 'Recursively search for files/directories',
        inputSchema: zodToJsonSchema(SearchFilesArgsSchema),
    },
    {
        name: 'get_file_info',
        description: 'Get detailed file/directory metadata',
        inputSchema: zodToJsonSchema(GetFileInfoArgsSchema),
    },
    {
        name: 'list_allowed_directories',
        description: 'List all directories the server is allowed to access',
        inputSchema: zodToJsonSchema(z.object({})),
    },
];
// Main server logic
server.setRequestHandler(ListToolsRequestSchema, async () => ({ tools }));
server.setRequestHandler(CallToolRequestSchema, async (request) => {
    const { name, arguments: toolArgs } = request.params;
    try {
        switch (name) {
            case 'read_file': {
                const { path: filePath, tail, head } = ReadFileArgsSchema.parse(toolArgs);
                const validatedPath = await validatePath(filePath);
                let content = await fs.readFile(validatedPath, 'utf-8');
                if (tail !== undefined) {
                    content = await tailFile(validatedPath, tail);
                }
                else if (head !== undefined) {
                    content = await headFile(validatedPath, head);
                }
                return { content: [{ type: 'text', text: content }] };
            }
            case 'read_multiple_files': {
                const { paths } = ReadMultipleFilesArgsSchema.parse(toolArgs);
                const results = await Promise.allSettled(paths.map(async (filePath) => {
                    const validatedPath = await validatePath(filePath);
                    const content = await fs.readFile(validatedPath, 'utf-8');
                    return { path: filePath, content };
                }));
                const fulfilled = results.filter(r => r.status === 'fulfilled').map(r => r.value);
                const rejected = results.filter(r => r.status === 'rejected').map(r => ({ path: r.reason?.path || 'unknown', error: r.reason?.message || 'unknown error' }));
                return { content: [{ type: 'json', json: { fulfilled, rejected } }] };
            }
            case 'write_file': {
                const { path: filePath, content } = WriteFileArgsSchema.parse(toolArgs);
                const validatedPath = await validatePath(filePath);
                await fs.writeFile(validatedPath, content, 'utf-8');
                return { content: [{ type: 'text', text: `File written: ${filePath}` }] };
            }
            case 'edit_file': {
                const { path: filePath, edits, dryRun } = EditFileArgsSchema.parse(toolArgs);
                const validatedPath = await validatePath(filePath);
                const diff = await applyFileEdits(validatedPath, edits, dryRun);
                return { content: [{ type: 'text', text: diff }] };
            }
            case 'create_directory': {
                const { path: dirPath } = CreateDirectoryArgsSchema.parse(toolArgs);
                const validatedPath = await validatePath(dirPath);
                await fs.mkdir(validatedPath, { recursive: true });
                return { content: [{ type: 'text', text: `Directory created: ${dirPath}` }] };
            }
            case 'list_directory': {
                const { path: dirPath } = ListDirectoryArgsSchema.parse(toolArgs);
                const validatedPath = await validatePath(dirPath);
                const entries = await fs.readdir(validatedPath, { withFileTypes: true });
                const formattedEntries = entries.map(entry => entry.isDirectory() ? `[DIR] ${entry.name}` : `[FILE] ${entry.name}`).join('\n');
                return { content: [{ type: 'text', text: formattedEntries }] };
            }
            case 'list_directory_with_sizes': {
                const { path: dirPath, sortBy } = ListDirectoryWithSizesArgsSchema.parse(toolArgs);
                const validatedPath = await validatePath(dirPath);
                let entries = await fs.readdir(validatedPath, { withFileTypes: true });
                const detailedEntries = await Promise.all(entries.map(async (entry) => {
                    const fullPath = path.join(validatedPath, entry.name);
                    try {
                        const stats = await fs.stat(fullPath);
                        return {
                            name: entry.name,
                            type: entry.isDirectory() ? 'DIR' : 'FILE',
                            size: stats.size,
                        };
                    }
                    catch (error) {
                        return {
                            name: entry.name,
                            type: entry.isDirectory() ? 'DIR' : 'FILE',
                            size: 0, // Or handle error appropriately
                            error: error.message,
                        };
                    }
                }));
                if (sortBy === 'name') {
                    detailedEntries.sort((a, b) => a.name.localeCompare(b.name));
                }
                else if (sortBy === 'size') {
                    detailedEntries.sort((a, b) => a.size - b.size);
                }
                const formattedEntries = detailedEntries.map(entry => {
                    if (entry.error) {
                        return `[${entry.type}] ${entry.name} (Error: ${entry.error})`;
                    }
                    return `[${entry.type}] ${entry.name} (${formatSize(entry.size)})`;
                }).join('\n');
                return { content: [{ type: 'text', text: formattedEntries }] };
            }
            case 'directory_tree': {
                const { path: dirPath } = DirectoryTreeArgsSchema.parse(toolArgs);
                const validatedPath = await validatePath(dirPath);
                let tree = '';
                async function buildTree(currentPath, indent) {
                    const entries = await fs.readdir(currentPath, { withFileTypes: true });
                    for (const entry of entries) {
                        const fullPath = path.join(currentPath, entry.name);
                        try {
                            await validatePath(fullPath); // Ensure each path in the tree is allowed
                            tree += `${indent}${entry.isDirectory() ? '📁' : '📄'} ${entry.name}\n`;
                            if (entry.isDirectory()) {
                                await buildTree(fullPath, indent + '  ');
                            }
                        }
                        catch (error) {
                            // Skip unreadable or unauthorized entries
                            tree += `${indent}🚫 ${entry.name} (Access Denied or Error)\n`;
                        }
                    }
                }
                tree += `📁 ${dirPath}\n`;
                await buildTree(validatedPath, '  ');
                return { content: [{ type: 'text', text: tree }] };
            }
            case 'move_file': {
                const { source, destination } = MoveFileArgsSchema.parse(toolArgs);
                const validatedSource = await validatePath(source);
                const validatedDestination = await validatePath(destination); // Ensure destination is also valid
                await fs.rename(validatedSource, validatedDestination);
                return { content: [{ type: 'text', text: `Moved ${source} to ${destination}` }] };
            }
            case 'search_files': {
                const { path: rootPath, pattern, excludePatterns } = SearchFilesArgsSchema.parse(toolArgs);
                const validatedRootPath = await validatePath(rootPath);
                const results = await searchFiles(validatedRootPath, pattern, excludePatterns);
                return { content: [{ type: 'text', text: results.join('\n') }] };
            }
            case 'get_file_info': {
                const { path: filePath } = GetFileInfoArgsSchema.parse(toolArgs);
                const validatedPath = await validatePath(filePath);
                const info = await getFileStats(validatedPath);
                return { content: [{ type: 'json', json: info }] };
            }
            case 'list_allowed_directories': {
                return { content: [{ type: 'json', json: allowedDirectories }] };
            }
            default:
                throw new Error(`Unknown tool: ${name}`);
        }
    }
    catch (error) {
        return {
            content: [{ type: 'text', text: `Error executing tool ${name}: ${error.message}` }],
            isError: true,
        };
    }
});
const transport = new StdioServerTransport();
server.connect(transport);
console.error("Filesystem MCP server running on stdio");
