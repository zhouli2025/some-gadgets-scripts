#Given an array of integers, return indices of the two numbers such that they add up to a specific target.

#You may assume that each input would have exactly one solution.


#intuition solution:

class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
        vector<int> a;
        for(int i = 0; i < nums.size() - 1; i++) {
            
            for(int j = i+1; j < nums.size(); j++) {
                
                if(nums[i] + nums[j] == target) {

                        a.push_back(i);
                        a.push_back(j);
                }
            }
        }
    return a;        
    }

};

#- how to utilize vector
#- j should equal to i + 1


#Time complexity : O(n^2)
#Space complexity : O(1)


#intuition solution:

#include  <map>
#include <iostream>

using namespace std;

class Solution {
public:
    vector<int> twoSum(vector<int>& nums, int target) {
    
        std::map<int, int> my_map;
        vector<int> result;
        
        for(int i = 0; i < nums.size(); i++) {
        //my_map.insert(nums[i],i);
        // or say 
        //my_map.insert(pair<int,int>(i,nums[i]));
	//
        //my_map.insert(map<int, int> :: value_type(nums[i], i));
	my_map[i]=nums[i];        

        int complement = target - nums[i];
        map<int, int>::iterator l_it;
        l_it = my_map.find(complement);
        
        if(l_it == my_map.end()) {
            // not found
            }else {
            if (i == l_it -> first) {    
   
            }else{
                
            result.push_back(l_it -> first);
            result.push_back(i);  
            
            }
            
        }
            
     }
     return result;
    }

};

#Time complexity : O(n)
#Space complexity : O(n)

