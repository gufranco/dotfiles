function octal(text,   i, value) {
  value = 0
  for (i = 1; i <= length(text); i++) value = value * 8 + substr(text, i, 1)
  return value
}
NR > sample { exit }
NF == 3 {
  written = octal($2)
  read = octal($3)
  lane = ($1 - 1) % 2
  bytes++
  for (bit = 0; bit < 8; bit++) {
    if (int(written / 2 ^ bit) % 2 == int(read / 2 ^ bit) % 2) continue
    line = lane * 8 + bit
    flips[line]++
    if (int(read / 2 ^ bit) % 2) high[line]++
    else low[line]++
  }
}
END {
  if (bytes == 0) exit
  printf "Bit report over %d wrong bytes%s:\n", bytes, (bytes >= sample ? ", the first " sample : "")
  lines = 0
  bits = 0
  for (line = 0; line < 16; line++) {
    if (!flips[line]) continue
    lines++
    used[lines] = line
    bit = line % 8
    if (!seen[bit]++) { bits++; bitlist[bits] = bit }
    bitup[bit] += high[line]
    bitdown[bit] += low[line]
    printf "  bit %d of %s bytes: wrong %d times, read 1 for 0 %d times, 0 for 1 %d times\n", bit, (line < 8 ? "even" : "odd"), flips[line], high[line] + 0, low[line] + 0
  }
  where = ""
  if (lines == 1) where = sprintf(" in %s bytes only, D%d on a 16-bit bus", (used[1] < 8 ? "even" : "odd"), used[1])
  only = bitlist[1]
  if (bytes < 16) {
    printf "Only %d wrong bytes, too few to tell a data line fault from a media defect.\n", bytes
  } else if (bits == 1 && (bitup[only] + 0 == 0 || bitdown[only] + 0 == 0)) {
    printf "Every error is bit %d reading as %d%s. One stuck data line: cable, connector, adapter or drive interface, not the media.\n", only, (bitup[only] ? 1 : 0), where
  } else if (bits == 1) {
    printf "Every error is bit %d%s, flipping both ways. One open or intermittent data line, not the media.\n", only, where
  } else if (lines == 2) {
    printf "Every error is on D%d or D%d of a 16-bit bus. Two lines failing alone point at a short between them or a bad contact, not the media.\n", used[1], used[2]
  } else if (bits == 2) {
    printf "Every error is bit %d or bit %d. Two lines failing alone point at a short between them or a bad contact, not the media.\n", bitlist[1], bitlist[2]
  } else {
    printf "Errors spread over %d bit positions. That points at the media or the read signal rather than one data line.\n", bits
  }
}
