#!/usr/bin/awk -f

# templater - takes a file and replaces a variable
# in a given template with the contents of another file.

# err() - Prints a supplied `text` to standard error.
# @text: Text to be printed to stderr.
function err (text) {
        print text > "/dev/stderr"
}


# The BEGIN matcher is a special type of matcher that
# gets executed whenever the AWK program is starting
# and no records have been matched yet.
BEGIN {
        if (ARGC != 3) {
                err("Error: not enough arguments.")
                err("")

                err("Usage: ./templater <content_file> <template_file>")
                err("Aborting.")
                exit 1
        }

        if (length(ENVIRON["PATTERN"]) == 0) {
                err("Error: no pattern specified.")
                err("")

                err("Specify a pattern via the `PATTERN` environment variable.")
                err("For example: ")
                err("  PATTERN=__CONTENT__ templater contents.txt template.txt")
                err("Aborting.")
                exit 1
        }
}

# By using the `NR=FNR` pattern we're able to specify
# an action that we want to perform only on the first
# file that we supply via the command line.
#
# FNR is a counter that keeps track of the current line
# in the current file that is being processed.
#
# NR is a counter that keeps track of the total number
# of lines that have been processed so far.
#
# By trying to match `NR==FNR` we can perform an action
# in the very first file. To visualize that, we can set
# up an experiment:
#
#       $ cat file1
#       a
#       b
#       c
#
#       $ cat file2
#       d
#       e
#
#       $ awk '{print FILENAME, NR, FNR, $0}' file1 file2
#       file1 1 1 a
#       file1 2 2 b
#       file1 3 3 c
#       file2 4 1 d -> not equal -> starts the second one
#       file2 5 2 e -> not equal
#
# In the action we can then store all the lines from
# the first file in memory so that we can use it later
# when we find the string to replace.
#
# By specifying the `next` statement, no further matching
# is performed for this record (line).
#
# ps.: we could also check `FILENAME`, like:
#       FILENAME==ARGV[1]
NR==FNR {
        content_lines[n++]=$0;
        next;
}

# Once we find the string to replace, we iterate over
# all the lines that we stored (from the first file)
# and then once we're done, we force AWK to immediately
# stop processing the current record so that it doesn't
# print `__CONTENT__` and don't proceed with performing
# further matches for this record (line).
#
# ps.: if you didn't want to take a variable here, for
# instance, have a fixed pattern to replace, you could
# simply use `/PATTERN/ { ... }`.
$0 ~ ENVIRON["PATTERN"] {
        for (i = 0; i < n; i++) {
                print content_lines[i];
        }
        next
}

# Given that 1 always evaluates to `true`, this is a match
# that will always occur.
#
# As we can either omit an action or a match (not both!),
# we can use a catch-all match (1) and let awk use the
# default action (print current line).
#
# This has the effect of printing all lines that didn't
# match the other matches that we specified above.
1