# Whence which command type etc.

Note: this document is the result of my research around path-search and command definition built-ins for my use (bash, zsh, tcsh, busybox, and minimal sh/POSIX scripting).

Because it's so accumulated I will not link much, but [this](https://unix.stackexchange.com/questions/85249/why-not-use-which-what-to-use-then/85250#85250) has a lot of the history and details.

# TL;DR

## csh

I want to... of a command | command | Return `>0` if command is: | Parsable? | Output Details/Notes
---|---|---|---|---
Do anything like this | **NOT POSSIBLE** | N/A | N/A | use `sh -c "command -v <COMMAND>"` etc.

## tcsh

I want to... of a command | command | Return `>0` if command is: | Parsable? | Output Details/Notes
---|---|---|---|---
Test the validity | ```if ( `where <COMMAND>` != "" ) then``` | Invalid<sup>1</sup> | No | **WARNING**: `printexitvalue` cannot be set. <br> *All* paths/functions/aliases found or empty if not found.
Find the path | **DIFFICULT** | N/A| N/A | No straightforward way
Get the type and path or definition | `which <COMMAND>` | Invalid<sup>1</sup> | No | Describes type, gives alias definition or path.
Ignore **builtins**/aliases and find the path | `which \<COMMAND>` | Not external<sup>1</sup> | No | stdout is either path or an error<sup>1</sup>. <br> Alias escaping only works for csh which/where.
Find all aliases and paths | `where <COMMAND>` | Invalid<sup>1</sup> | No | Alias definition and all paths if found or empty if not found.

<sup>1</sup>Some versions of tcsh did not return an error status for a failing which/where. Where gives no text on not found, which prints error **to stdout** \

## POSIX/busybox/Portable

I want to... of a command | command | Return `>0` if command is: | Parsable? | Output Details/Notes
---|---|---|---|---
Test the validity or find the path | `if command -v <COMMAND>; then` or `cmdpath="$( comamnd -v <COMMAND> )"` | Invalid | Yes | `<COMMAND>` for builtins & functions. <br> `alias <COMMAND>='<definition>'`  for alias. <br> Path of binary found. <br> "" if not found.
Get the type and path or definition | `command -V` | Invalid | No | Describes type, gives alias definition or path. May not give function definition<sup>2</sup>.
Ignore **builtins**/aliases/functions and find the path | `which <COMMAND>` | Not external | Yes | Which is **NOT** a builtin and should be used with caution. Also available in bash.
Find all paths | `which -a` | Not external | No | Which is **NOT** a builtin and should be used with caution.

Note: busybox has some extra compatibility to avoid *errors* on bashisms, but rarely has the added functionality that comes with bash's tools.

<sup>2</sup>Getting function definitions can be tricky as this is not defined in POSIX. If `command -V` and `type` do not work it is unlikely there is a way.

## bash

I want to... of a command | command | Return `>0` if command is: | Parsable? | Output Details/Notes
---|---|---|---|---
Test the validity or find the path | `if command -v <COMMAND>; then` or `cmdpath="$( comamnd -v <COMMAND> )"` | Invalid | Yes | See POSIX table for standard output
Find *only* the path |  `type -p` | Invalid | Yes | Blank if builtin/alias/function.
Get the type and path or definition |  `type <COMMAND>` | Invalid | No | Describes type, gives alias/function definition or path.
Ignore **builtins**/aliases/functions and find the path |  `type -P` | Not external | Yes | Simple path, blank if alias/function.
Find all aliases/functions and paths |  `type -a` | Invalid | No | The standard `type` output plus additional path(s).

## zsh

I want to... of a command | command | Return `>0` if command is: | Parsable? | Output Details/Notes
---|---|---|---|---
Test the validity or find the path | `if command -v <COMMAND>; then` or `cmdpath="$( comamnd -v <COMMAND> )"` | Invalid | Yes | See POSIX table for standard output
Get the type and path or definition | `whence -v -f` | Invalid | No | `whence -c` emulates csh where output which is similar (not sure if/how it differs)
Ignore **builtins**/aliases/functions and find the path | `whence -p` | Not external | Yes | The path-only switch `-p` is combinable with other whence options like `-v`.
Find all aliases/functions and paths | `whence -a` | Invalid | Yes | Output matches `command -v` with multiple lines. <br> Combinable with `-v -f` for type-like output.
Also de-reference symlinks in paths |  `whence -s` | Invalid | Sort-of | Any paths which are symlinks have `-> <TARGET>` printed after.

# Details commands

## alias | grep (all)

A simple option if you know you're looking for an alias. Usual grep returns/errors apply.

- `alias | grep "<COMMAND>="` for POSIX, busybox, bash, zsh
- `alias | grep "^<COMMAND>"` for (t)csh

## command (non-tcsh)

The [POSIX-standard](http://pubs.opengroup.org/onlinepubs/9699919799/utilities/command.html) command utility is useful in many ways.

- `command -v <COMMAND>` prints `<COMMAND>` if it is a builtin, reserved word, alias, or function. Then searches path and prints that if found. If not found there is no print, but error code >0.
- `command -V <COMMAND>` prints details of `<COMMAND>` including its type (builtin, alias, function, reserved words, etc.) in more natural language. It will print alias definitions and paths usually, but functions definitions are less likely. If not found errors may print to stdout or stderr with an error code <0.

## declare/typeset -f (bash/zsh)

Not very portable, but `declare/typeset -f <COMMAND>` prints function definitions (all if no `<COMMAND>` given)

## Hash (TODO)

TODO: more details on [hashing](pubs.opengroup.org/onlinepubs/9699919799/utilities/hash.html) overrides path when executing a file. Some of these utilities ignore it, others print the path that would be executed. (is tcsh hashing manipulatable?)

## type (non-tcsh but not equal)

Type is defined by the POSIX standard, but *very* loosely. It can accept multiple commands and processes each separately.

- In basic shells a (sometimes shorter) version of `command -V`, rarely accepts switches
- In bash `type` is more robust and the most-useful utility
  - `type -t <COMMAND>` returns a single-word type in `{'alias', 'function', 'builtin', 'file', 'keyword'}`. No error is printed but exit >0 if invalid.
  - `type -p <COMMAND>` returns either the path to a file or nothing if not a file. No error if printed, exit is only >0 if command is invalid.
  - `type -P <COMMAND>` forces a path search. Output format is similar to `type -p` but will show paths for collisions (where `type -p` prints nothing). Exit is >0 if no file is found (even if the command is valid).
  - `type -a <COMMAND>` returns all matches (including functions/aliases/builtins unless combined with `-p`).
  - `type -f <COMMAND>` ignores functions (and continues searching or errors if not found).
- In busybox `type` is just `command -v` and ignores switches
- In zsh `type` is a builtin that points to `whence -v`.

## whence (zsh)

Whence is zsh's main tool, and most others point here (except `command` for POSIX compliance). It can accept multiple commands and processes each separately. Useful examples are below but see [the man pages](http://zsh.sourceforge.net/Doc/Release/Shell-Builtin-Commands.html) for switch details. Dropping `-v` and `-f` keep things grokable.

`whence [ -vcwfpamsS ] <COMMAND>`

- `whence -v <COMMAND>` has a verbose output (matching POSIX `command -V` without function definitions).
- `whence -vf <COMMAND>` includes function definitions in verbose out (roughly matches bash `command -V`).
- `whence -c <COMMAND>` has a verbose output matching (t)csh `which`. Differences to `-v -f` are unknown.
- `whence -w <COMMAND>` is similar to bash's `type -t` but of format `<COMMAND>: {'alias', 'builtin', 'command', 'function', 'hashed', 'reserved', 'none'}` with `none` printed and an exit code >0 when not found.
- `whence -vfp <COMMAND>` similar to bash's `type -P` forces a path search ignoring all aliases/builtins/functions/etc.. Exit is >0 if no file is found (even if the command is valid).
- `whence -vfa <COMMAND>` returns all matches (including functions/aliases/builtins).
- `-m -s -S` have no similar version in other shells covered here, but allow matching (all matches are printed), and show symlink targets (without and with intermediate steps).

## where (tcsh, zsh)

Where is the multi-result tool for tcsh (like `type/whence -a`). Can be used `where \<COMMAND>` to force a path search (bypassing builtins, reserved words, aliases, etc.).

zsh has a builtin that equates `where` to `whence -ac`

## which (all but not equal)

- In csh `which` script was written that (clumsily) parses the tcsh environment and searches aliases or paths. It is not advised for use, instead use `sh -c command <COMMAND>` or something else from a different shell
- In tcsh `which <COMMAND>` **is the main method of finding a command**.
  - It only returns pretty output or an error.
  - Errors are to stdout but *usually* have an error code >0. Some versions did not provide an error code.
  - Can be used `where \<COMMAND>` to force a path search (bypassing builtins, reserved words, aliases, etc.).
  - This path-only form is helpful for groking paths due to the lack of a non-pretty output in tcsh.
- In bash and most POSIX shells `which` is an external binary, but `type [-afptP]` is **much** better
  - This is useful for searching **only** path, but may be inaccurate as a result. There are also various eccentricities that can cause the non-first option to be listed.
  - It usually has an `-a` option to print all valid paths.
- In zsh `which` is a builtin that points to `whence -c`.
