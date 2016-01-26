package main

import (
	"crypto/rand"
	"fmt"
	"os"
	"strconv"
	// "io"
	"math/big"
	// "strings"
)

func main() {
	var start, end int
	var err error
	argLen := len(os.Args)
	if argLen == 1 {
		start = 0
		end = 100
	} else if argLen == 2 {
		start = 0
		end, err = strconv.Atoi(os.Args[1])
		if err != nil {
			fmt.Printf("usage error:%v\n", err)
			return
		}
	} else if argLen == 3 {
		start, err = strconv.Atoi(os.Args[1])
		if err != nil {
			fmt.Printf("usage error:%v\n", err)
			return
		}
		end, err = strconv.Atoi(os.Args[2])
		if err != nil {
			fmt.Printf("usage error:%v\n", err)
			return
		}
	} else {
		fmt.Println("usage error")
	}
	ret, _ := rand.Int(rand.Reader, big.NewInt(int64(end-start)))
	fmt.Println(ret.Int64() + int64(start))
}
