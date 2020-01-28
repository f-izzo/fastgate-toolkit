#!/bin/bash


decToHex(){
   local decValue="$1"
   printf '0x%x' $decValue
}

getString(){
   local filename="$1"
   local startPos="$2"
   local length="$3"

   echo "$(tail -c +$(($startPos + 1)) $filename|head -c $length)"
}

getUInt32LE(){
    local filename="$1"
    local startPos="$2"
    local length=4
    local hexValue="$(tail -c +$(($startPos + 1)) $filename|head -c $length|xxd -u -e|cut -d" " -f2)"

    echo $((16#$hexValue))
}

makeElf(){
    local input="$1"
    local output="$2"
    objcopy \
        -I binary \
        -O elf32-littlearm \
        -B arm \
        "${input}" "${output}"
}

unpackBoot(){
    local input="$1"
    local output="$2"

    tail -c +$((0x15)) "${input}" | lzma -dc > "${output}"
}

link(){
    local linkscript_template="$1"
    local input_template="$2"
    local text_blob_file="$3"
    local codeAddr="$4"
    local entrypAddr="$5"
    local output="$6"

    local ldScript="${linkscript_template%.m4}"
    local input="${input_template%.m4}"
    local m4Replacement="-DM4_INC_BINARY="${text_blob_file}" -DM4_CODE_ADDR="${codeAddr}" -DM4_ENTRYP_ADDR="${entrypAddr}""
    m4 $m4Replacement "${linkscript_template}" > "${ldScript}"
    m4 $m4Replacement "${input_template}" > "${input}"

    gcc -v "${input}" \
        -o "${output}" \
        -ffreestanding \
        -nostartfiles \
        -nodefaultlibs \
        -Wl,-T "${ldScript}" \
        -Wl,--build-id=none \
        -Wl,--print-memory-usage \
        -Wl,--print-output-format \
        -Wl,--print-map \
        || exit 1

    readelf -a "${output}"
}


convert(){
    local codeAddr=$(getUInt32LE "vmlinux.lz" 0x0)
    local entryPointAddr=$(getUInt32LE "vmlinux.lz" 0x4)
    local compressedLength=$(getUInt32LE "vmlinux.lz" 0x8)
    local magic=$(getString "vmlinux.lz" 0xC 4)

    echo "[+] Parsing compressed file..."

    if [[ $magic != "BRCM" ]]
    then
      echo "[-] Invalid Magic"
      exit 1
    fi

    echo "[+] File info"
    printf 'Code Addr:         0x%x\n' $codeAddr
    printf 'EntryPoint Addr:   0x%x\n' $entryPointAddr
    printf 'Compressed Length: 0x%x\n' $compressedLength
    printf 'Magic:             %s\n' $magic

    # local codeAddrHex=$(decToHex $codeAddr)
    # Zero out top 8 bits
    local codeAddrHex=$(decToHex $(($codeAddr & 0xFFFFFFF)))
    local entrypAddrHex=$(decToHex $(($entryPointAddr & 0xFFFFFFF)))

    echo "[+] Unpacking file..."
    unpackBoot "vmlinux.lz" "image.bin"
    echo "[+] Linking new ELF"
    link "bootp.lds.m4" "kernel.S.m4" "image.bin" "$codeAddrHex" "$entrypAddrHex" "vmlinux.elf"
}

convert
rm bootp.lds
rm kernel.S
rm image.bin
