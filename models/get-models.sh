#!/bin/bash
#
# Download OpenFace models.

cd "$(dirname "$0")"

die() {
  echo >&2 $*
  exit 1
}

checkCmd() {
  command -v $1 >/dev/null 2>&1 \
    || die "'$1' command not found. Please install from your package manager."
}

checkCmd wget
checkCmd bunzip2

mkdir -p dlib
if [ ! -f dlib/shape_predictor_68_face_landmarks.dat ]; then
  printf "\n\n====================================================\n"
  printf "Downloading dlib's public domain face landmarks model.\n"
  printf "Reference: https://github.com/davisking/dlib-models\n\n"
  printf "This will incur about 60MB of network traffic for the compressed\n"
  printf "models that will decpmoress to about 100MB on disk.\n"
  printf "====================================================\n\n"
  wget -nv http://dlib.net/files/shape_predictor_68_face_landmarks.dat.bz2 \
    -O dlib/shape_predictor_68_face_landmarks.dat.bz2
  [ $? -eq 0 ] || die "+ Error in wget."
  bunzip2 dlib/shape_predictor_68_face_landmarks.dat.bz2
  [ $? -eq 0 ] || die "+ Error using bunzip2."
fi

mkdir -p openface
if [ ! -f openface/nn4.v2.t7 ]; then
  printf "\n\n====================================================\n"
  printf "Downloading OpenFace models.\n"
  printf "The nn4.v2.t7 and celeb-classifier.nn4.v2.pkl models are\n"
  printf "Copyright Carnegie Mellon University and are licensed under\n"
  printf "the Apache 2.0 License.\n\n"
  printf "This will incur about 500MB of network traffic for the models.\n"
  printf "====================================================\n\n"

  wget -nv http://openface-models.storage.cmusatyalab.org/nn4.v2.t7 \
    -O openface/nn4.v2.t7
  [ $? -eq 0 ] || ( rm openface/nn4.v2.t7* && die "+ nn4.v2.t7: Error in wget." )

  wget -nv http://openface-models.storage.cmusatyalab.org/celeb-classifier.nn4.v2.pkl \
    -O openface/celeb-classifier.nn4.v2.pkl
  [ $? -eq 0 ] || ( rm openface/celeb-classifier.nn4.v2.pkl && \
                    die "+ celeb-classifier.nn4.v2.pkl: Error in wget." )
fi

printf "\n\n====================================================\n"
printf "Verifying checksums.\n"
printf "====================================================\n\n"

md5str() {
  local FNAME=$1
  case $(uname) in
    "Linux")
      echo $(md5sum "$FNAME" | cut -d ' ' -f 1)
      ;;
    "Darwin")
      echo $(md5 -q "$FNAME")
      ;;
  esac
}

checkmd5() {
  local FNAME=$1
  local EXPECTED=$2
  local ACTUAL=$(md5str "$FNAME")
  if [ $EXPECTED == $ACTUAL ]; then
    printf "+ $FNAME: successfully checked\n"
  else
    printf "+ ERROR! $FNAME md5sum did not match.\n"
    printf "  + Expected: $EXPECTED\n"
    printf "  + Actual: $ACTUAL\n"
    printf "  + Please manually delete this file and try re-running this script.\n"
    return -1
  fi
  printf "\n"
}

set -e

checkmd5 \
  dlib/shape_predictor_68_face_landmarks.dat \
  73fde5e05226548677a050913eed4e04

checkmd5 \
  openface/celeb-classifier.nn4.v2.pkl \
  0d1c6e3ba4fd28580c4aa34a3d4eca04

checkmd5 \
  openface/nn4.v2.t7 \
  71911baa0ac61b437060536f0adb78f4
