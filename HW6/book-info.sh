#!/bin/bash


if [[ ! -f $1 ]] ; then
  echo "File $1 not found"
  exit
fi

file=$1

while read -r chapter ; do             # read line 1 by 1 in the input file
    if [[ ! -f $chapter ]] ; then
     echo "File $chapter not found"
     exit
    fi
done < $file

echo "Enter: number / files / names / stats <chapter-name> / search <word>/ quit"        # print the available inputs

while read line; do                    # take input from the standard input


    if [[ $line == "quit" ]]; then
      break
    fi
    
    if [[ $line == "number" ]] ; then
        n=0
        while read -r chapter ; do
          if [[ -f $chapter ]] ; then
            n=$((n+1))
          fi
        done < $file
        echo $n chapters
    fi
    
    if [[ $line == "files" ]] ; then
        while read -r chapter ; do
          prefix=$(head -n1 $chapter | sed 's/$/:/')
          echo "$prefix $chapter" >> chapters.txt                           # print to another file
        done < $file
        
        sort chapters.txt                                                   # print the file sorted, then delete it
        rm chapters.txt
    fi
    
    if [[ $line == "names" ]] ; then
        while read -r chapter ; do
          prefix=$(head -n1 $chapter | sed 's/$/:/')
          name=$(head -n3 $chapter | tail -n1)
          echo "$prefix $name" >> chapterNames.txt                          # print to another file
        done < $file
        if [[ -f chapterNames.txt ]] ; then
          sort chapterNames.txt                                             # print the file sorted, then delete it
          rm chapterNames.txt
        fi
    fi
    
    if [[ $line =~ ^"stats"  ]] ; then
      while read -r chapter ; do
        prefix=$(head -n1 $chapter | sed 's/$/:/')
        linesStats=$(sed -n '1,2!p' $chapter | wc -l | sed 's/$/ lines,/')
        wordsStats=$(sed -n '1,2!p' $chapter | wc -w | sed 's/$/ words/')
        echo "$prefix $linesStats $wordsStats" >> chapterStats.txt          # print to another file
      done < $file
    
      if [[ $line == "stats" ]] ; then
        if [[ -f chapterStats.txt ]] ; then
          sort chapterStats.txt                                             # print the file sorted, then delete it
          rm chapterStats.txt
        fi
        
      else
        if [[ -f chapterStats.txt ]] ; then
          search=$(echo $line | sed 's/stats//')
          grep $search chapterStats.txt
          rm chapterStats.txt
        fi
      fi
    fi
    
    if [[ $line =~ ^"search "  ]] ; then
      regex=$(echo $line | sed 's/search//g')
      while read -r chapter ; do
        prefix=$(head -n1 $chapter | sed 's/$/:/')
        appears=$(grep -E -w -i $regex $chapter | wc -l)
        if [[ $appears -gt 0 ]]; then
          echo "$prefix $appears" >> shows.txt                              # print to another file
        fi
      done < $file
      
      if [[ -f shows.txt ]] ; then
        sort shows.txt
        rm shows.txt                                                        # delete the file to avoid multiple outputs
      fi
    fi
    
    echo "Enter: number / files / names / stats <chapter-name> / search <word>/ quit"
    
done

