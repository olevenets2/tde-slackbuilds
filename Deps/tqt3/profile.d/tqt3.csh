#!/bin/csh
# Environment path variables for the Qt package:
if ( ! $?QTDIR ) then
    # It's best to use the generic directory to avoid
    # compiling in a version-containing path:
    if ( -d $TQTDIR ) then
        setenv QTDIR $TQTDIR
    else
        # Find the newest Qt directory and set $QTDIR to that:
        foreach qtd ( $TQTDIR-* )
            if ( -d $qtd ) then
                setenv QTDIR $qtd
            endif
        end
    endif
endif
