unset PATH
for p in $baseInputs $buildInputs
do
    export PATH="$p/bin${PATH:+:}$PATH"
done
