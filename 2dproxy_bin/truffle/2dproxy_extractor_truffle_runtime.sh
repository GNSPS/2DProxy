#!/usr/bin/env bash
# 
# ██████╗ ██████╗ ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗    ███████╗██╗  ██╗████████╗██████╗  █████╗  ██████╗████████╗ ██████╗ ██████╗ 
# ╚════██╗██╔══██╗██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝    ██╔════╝╚██╗██╔╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗
#  █████╔╝██║  ██║██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝     █████╗   ╚███╔╝    ██║   ██████╔╝███████║██║        ██║   ██║   ██║██████╔╝
# ██╔═══╝ ██║  ██║██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝      ██╔══╝   ██╔██╗    ██║   ██╔══██╗██╔══██║██║        ██║   ██║   ██║██╔══██╗
# ███████╗██████╔╝██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║       ███████╗██╔╝ ██╗   ██║   ██║  ██║██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║
# ╚══════╝╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝       ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
# 
# Truffle external compiler version
# for the runtime
# 

# 
# Function Definitions
# 

function log2 {
    local x=0
    for (( y=$1-1 ; $y > 0; y >>= 1 )) ; do
        let x=$x+1
    done
    echo $x
}

function ctor_creator {
	let extracted_size=$1/2

	let extracted_bytesize=($(log2 "$extracted_size")-1)/8
	let extracted_bytesize_chars=(extracted_bytesize+1)*2

	printf_format_extracted_str="%0"$extracted_bytesize_chars"x"

	let ctor_size=11+extracted_bytesize

	echo "6"$extracted_bytesize$(printf "$printf_format_extracted_str" "$extracted_size")"6000818160"$(printf "%02x" "$ctor_size")"9039f3"
}

# 
# Main 
# 

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <solidity_file_path>"
  exit 1
fi


filepath=$1
target_contract_name=$(basename "${filepath%.*}")

solc -o ./ --overwrite --optimize --bin "$filepath"

orig_bytecode=$(cat "${target_contract_name%.*}.bin")

orig_bytecode_size=${#orig_bytecode}

if (( $orig_bytecode_size % 2 != 0 ))
then
	# echo "$orig_bytecode"
	echo "The bytecode you provided doesn't have an even number of characters. Please check."
    echo
    echo "Ending..."
    exit 1;
fi

# 
# Constructor bytecode extraction part
# 

extracted_ctor=$(echo "$orig_bytecode" | sed 's/\(f300\)\(.*\)/\1/')

extracted_ctor_size=${#extracted_ctor}

if (( $extracted_ctor_size % 2 != 0 ))
then
	# echo "$extracted_ctor"
	echo "The bytecode of the extracted constructor doesn't have an even number of characters. Please check the validity of your bytecode."
    echo
    echo "Ending..."
    exit 1;
fi

# 
# Runtime bytecode extraction part
# 

extracted_runtime=$(echo "${orig_bytecode:$extracted_ctor_size}")

extracted_runtime_size=${#extracted_runtime}

if (( $extracted_runtime_size % 2 != 0 ))
then
	# echo "$extracted_runtime"
	echo "The bytecode of the extracted runtime part doesn't have an even number of characters. Please check the validity of your bytecode."
    echo
    echo "Ending..."
    exit 1;
fi

ctor_runtime=$(ctor_creator "$extracted_runtime_size")


echo "{
  \"contractName\":\""$target_contract_name"_runtime\",
  \"abi\":[],
  \"bytecode\":\"0x"$ctor_runtime$extracted_runtime"\",
  \"deployedBytecode\":\"0x"$extracted_runtime"\"
}"


