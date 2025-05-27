#include <map>
#include <iostream>
#include <cstring>
#include <string>
#include <stdio.h>
#include <fstream>
#include <vector>
#include <sstream>

using namespace std;

// map<string, string> targetClassMap;
// map<string, string>::iterator tIt;
map<string, vector<string>> targetClassMap;
map<string, vector<string>>::iterator tIt;

int main(int argc, char** argv) {

    // cout << "ciao" << endl;

    FILE *op;
    char path[10000];
    strcpy(path, "./log.txt");

    // cout << path << endl;
    // op = fopen(path, "r");
    // if(op != nullptr) {
    //     char tmp[10000];
    //     char tmp2[10000];

    //     while(fscanf(op, "%s %s", tmp, tmp2) != EOF) {
    //         string targetClass(tmp);
    //         string targetClassMangled(tmp2);

    //         cout << "-> " << tmp << " - " << tmp2 << endl;

    //         // tIt = targetClassMap.find(targetClass);
    //         // if (tIt == targetClassMap.end()) {
    //         //     targetClassMap.insert(pair<string,string>(targetClass, targetClassMangled));
    //         // }
    //     }

    //     fclose(op);
    // }

    string line;
    ifstream myfile;
    myfile.open(path);

    if(!myfile.is_open()) {
      perror("Error open");
      exit(EXIT_FAILURE);
    }
    
    while(getline(myfile, line)) {
        cout << line << endl;
        // for (unsigned i = 0; i < line.length(); i++)
        //     if (line[i] == ' ')
        //         n_token++;

        // vector<string> tokens;
        istringstream f(line);
        string s;    

        int n_token = 0;
        string targetClass;
        vector<string> tokens;
        while (getline(f, s, ' ')) {
            if (s == "")
                continue;
            if (n_token == 0)
                targetClass = s;
            else 
                tokens.push_back(s);
            n_token++;
        }

        tIt = targetClassMap.find(targetClass);
        if (tIt == targetClassMap.end()) {
            targetClassMap.insert(pair<string,vector<string>>(targetClass, tokens));
            cout << "added new one" << endl;
        } else {
            cout << "already present" << endl;
        }

        cout << endl;
    }

    cout << "I print what I found" << endl << endl;

    for (auto it: targetClassMap) {
        string class_name = it.first;
        vector<string> tokens_2 = it.second;
        cout << "class: " << class_name << endl;
        int x = 0;
        for (string t: tokens_2) {
            if (x == 0)
                cout << "constructor: " << t << endl;
            else
                cout << "param: " << t << endl;
            x++;
        }
        cout << endl;
    }

    return 0;
}