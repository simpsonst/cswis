# Purpose

This package provides C headers for use with RISC OS programs that call SWIs.
The headers define macros with the SWI names and numbers as the macro names and values.
For example, if you want to use the SWI `MessageTrans_MakeMenus` (number 0x41503), you can use:

```
#include <riscos/swi/MessageTrans.h>

your_favourite_swi_wrapper(MessageTrans_MakeMenus, arguments);
```

Other headers exist for service codes, error codes, Wimp messages and events:

```
#include <riscos/services.h>
#include <riscos/error/URI.h>
#include <riscos/wimp/events.h>
#include <riscos/wimp/messages.h>
#include <riscos/wimp/message/PlugIn.h>
```

The sets of symbolic constants are split up to allow incremental development.
For example, if you develop a module that provides SWIs with the prefix Zarking, then they aren't likely to have appeared in everyone's `<swis.h>` yet, so you can't `#include` that, and you can't expect everyone to patch their `<swis.h>` just for your codes.
Instead, you define that they come from `<riscos/swis/Zarking.h>`, and a fellow
developer merely has to merge your development header file into his `#include` path.
When your module becomes more formal, no-one has to change any source code that `#include`s your SWI constants &ndash; they remain under the same virtual path.

Another possible benefit is that the tables could be used to generate
constants for other languages.

(There are also headers for assembly language.
Is there no way to get the assembler to search though a path specified on the command line, so that `CSWIs:` can be omitted?)


# Creating new headers

Headers are designed to be built under Linux using tools such as GNU Make and GNU Awk.
The source table for the header `<riscos/foo.h>` can be found in `tables/foo.tab`.
Tables have the following format:

```
![<prefix>,<base>,<format>]+
<name>,<value>
<name>,<value>
<name>,<value>
...
```

For each `<prefix>`, the name `<prefix><name>` is defined to have `<value>+<base>`.
Values are expressed using `#x` format by default, but you can specify (e.g.) `d` for base 10.
`!` lines may appear multiple times in the same file, indicating a new batch of name-value pairs that should be translated into the same file but with different
prefixes and bases.
