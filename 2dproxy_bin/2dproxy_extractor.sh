#!/usr/bin/env bash
# 
# ██████╗ ██████╗ ██████╗ ██████╗  ██████╗ ██╗  ██╗██╗   ██╗    ███████╗██╗  ██╗████████╗██████╗  █████╗  ██████╗████████╗ ██████╗ ██████╗ 
# ╚════██╗██╔══██╗██╔══██╗██╔══██╗██╔═══██╗╚██╗██╔╝╚██╗ ██╔╝    ██╔════╝╚██╗██╔╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗
#  █████╔╝██║  ██║██████╔╝██████╔╝██║   ██║ ╚███╔╝  ╚████╔╝     █████╗   ╚███╔╝    ██║   ██████╔╝███████║██║        ██║   ██║   ██║██████╔╝
# ██╔═══╝ ██║  ██║██╔═══╝ ██╔══██╗██║   ██║ ██╔██╗   ╚██╔╝      ██╔══╝   ██╔██╗    ██║   ██╔══██╗██╔══██║██║        ██║   ██║   ██║██╔══██╗
# ███████╗██████╔╝██║     ██║  ██║╚██████╔╝██╔╝ ██╗   ██║       ███████╗██╔╝ ██╗   ██║   ██║  ██║██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║
# ╚══════╝╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝       ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
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
  echo "Usage: $0 output_filename <bytecode | -f binary_filename | -s [-o] solidity_filename target_contract_name>"
  echo ""
  echo "Options"
  echo "	-f : enables you to provide a filename with the compiled bytecode instead of a string"
  echo "	-s : enables you to provide a filename with the Solidity source code"
  echo "	-o : runs the solc compiler with optimization on (runs==200)"
  exit 1
fi


# INIT VARS
orig_bytecode=""
NEXT_IS_FILE=0
NEXT_IS_SOL_FILE=0
NEXT_IS_TARGET_CONTRACT=0
OPTIMIZATION_ON=0


# Get output file first
OUTPUT_FILE_PREFIX=$1
shift

for var in "$@"
do
	if [ "$var" = "-f" ]; then
		NEXT_IS_FILE=1
	elif [ "$var" = "-s" ]; then
		NEXT_IS_SOL_FILE=1
	elif [ "$var" = "-o" ]; then
		OPTIMIZATION_ON=1
	elif [ "$NEXT_IS_FILE" -eq 1 ]; then
		NEXT_IS_FILE=0

		orig_bytecode=$(cat "$var")
	elif [ "$NEXT_IS_SOL_FILE" -eq 1 ]; then
		NEXT_IS_SOL_FILE=0
		NEXT_IS_TARGET_CONTRACT=1

		if [ "$OPTIMIZATION_ON" -eq 1 ]; then
			solc -o ./ --overwrite --optimize --bin "$var"
		else
			solc -o ./ --overwrite --bin "$var"
		fi
	elif [ "$NEXT_IS_TARGET_CONTRACT" -eq 1 ]; then
		orig_bytecode=$(cat "${var%.*}.bin")

		rm "${var%.*}.bin"
	else
		orig_bytecode="$var"
	fi
done

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

ctor_ctor=$(ctor_creator "$extracted_ctor_size")


echo $ctor_ctor$extracted_ctor > "$OUTPUT_FILE_PREFIX""_ctor.sol.bin"

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

echo $ctor_runtime$extracted_runtime > "$OUTPUT_FILE_PREFIX""_runtime.sol.bin"

