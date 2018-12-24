package main

import (
    "fmt"
    "os/exec"
    "sync"
    "encoding/json"
    "log"
    "net/http"
    "github.com/gorilla/mux"
)

//load test go performance on 1000 sh command
func loadTestSysCommand() {
    
    wg := new(sync.WaitGroup)            // wait till responce
    for i := 0; i < 1000; i++ {
        wg.Add(1)
        out, err := exec.Command(commmand).Output()
        if err != nil {
          fmt.Printf("%s", err)
        }
        fmt.Printf("%s", out)
        wg.Done()
    }
    wg.Wait() 

}

// kill process with ip
func KillProcess(w http.ResponseWriter, r *http.Request) {
    
    params := mux.Vars(r)
    ip = params["id"]

    wg := new(sync.WaitGroup)                       // wait till process killed.
    out, err := exec.Command("pkill", "-f", ip).Output()
    if err != nil {
      fmt.Printf("%s", err)
      return json.NewEncoder(w).Encode(err)
    }
    fmt.Printf("%s", out)
    wg.Done()

    return json.NewEncoder(w).Encode("success")

}

func main() {

    //loadTestSysCommand()

   router := mux.NewRouter()
   log.Fatal(http.ListenAndServe(":8000", router))

   router.HandleFunc("/kill/process", KillProcess).Methods("DELETE")
   
   fmt.Printf("done-------------")
}