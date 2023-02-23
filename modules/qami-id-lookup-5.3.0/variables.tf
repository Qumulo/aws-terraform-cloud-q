#MIT License

#Copyright (c) 2021 Qumulo, Inc.

#Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the Software), to deal 
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all 
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
#SOFTWARE.

variable "aws_region" {
  description = "AWS Region"
  type = string
}
variable "marketplace_short_name" {
  description = "Qumulo AWS marketplace type abbreviated"
  type = string
}

variable "region_map" {
  description = "Qumulo AMI-IDs mapped to marketplace type and region"
  default = {
    "us-east-1" = {
      "1TB" = "ami-053d5559854d0f77e"
      "12TB" = "ami-0ad8d302106ee2487"
      "96TB" = "ami-0e47861a1a8a0a005"
      "103TB" = "ami-0898069252096e6d5"
      "270TB" = "ami-0eda0cba628c0b68c"
      "809TB" = "ami-035c4e9fd8f68e72d"
      "Custom" = "ami-032d36d831b2435aa"
    }
    "us-east-2" = {
      "1TB" = "ami-034d36d8954898a3f"
      "12TB" = "ami-09aba5d3a7b21d342"
      "96TB" = "ami-03c795266f07cfe12"
      "103TB" = "ami-0594e4baa7364296f"
      "270TB" = "ami-0ea8d9919280b0eb8"
      "809TB" = "ami-0810c8a290f4daaeb"
      "Custom" = "ami-0518fb4af56a61198"
    }
    "us-west-1" = {
      "1TB" = "ami-06464c9b159b9a127"
      "12TB" = "ami-07183212985b04bbb"
      "96TB" = "ami-0385405cd250ba6e1"
      "103TB" = "ami-09efa95763e198a40"
      "270TB" = "ami-035b565e317ed2871"
      "809TB" = "ami-02ac9424b6b8e330a"
      "Custom" = "ami-0fa43101ae578e760"
    }
    "us-west-2" = {
      "1TB" = "ami-0df25a58653528373"
      "12TB" = "ami-057b35fa6859fa52a"
      "96TB" = "ami-0e5959ea508ac1c0e"
      "103TB" = "ami-04a007257011750ad"
      "270TB" = "ami-0ce6300d094bbef61"
      "809TB" = "ami-00364eb754d9f9a04"
      "Custom" = "ami-04e83ac511793996f"
    }
    "us-gov-west-1" = {
      "1TB" = "ami-0f38b667f3b0786f2"
      "12TB" = "ami-029cb8cf729cceeac"
      "96TB" = "ami-0653f3b44e94efb1a"
      "103TB" = "ami-0fd889187261f6223"
      "270TB" = "ami-096d4391083a571e6"
      "809TB" = "ami-0efe84ffd88bd5f26"
      "Custom" = "ami-050731cf3fb56df19"
    }
    "us-gov-east-1" = {
      "1TB" = "ami-0287c25729dc6d4c6"
      "12TB" = "ami-00f4c3ddfcd95d511"
      "96TB" = "ami-0a99b5fca0a4cfc97"
      "103TB" = "ami-0931276bb82b99763"
      "270TB" = "ami-03fab4fc416516045"
      "809TB" = "ami-0ad4de011ffed5334"
      "Custom" = "ami-023324c6949c67aa3"
    }
    "ca-central-1" = {
      "1TB" = "ami-04b0cc134549674fc"
      "12TB" = "ami-042f76054a36f41c2"
      "96TB" = "ami-06a762399ee2a961a"
      "103TB" = "ami-073ebd92518daa953"
      "270TB" = "ami-0e44e3af4e51fb574"
      "809TB" = "ami-069fc0456e920fb8f"
      "Custom" = "ami-08c790d9a24353d98"
    }
    "eu-central-1" = {
      "1TB" = "ami-079674c686b905ee9"
      "12TB" = "ami-01ffabc09c13d2f2d"
      "96TB" = "ami-0d188426542096750"
      "103TB" = "ami-0be710d5ca74dda8d"
      "270TB" = "ami-08661b1fab7bef255"
      "809TB" = "ami-0ba436a3fbc5ebce8"
      "Custom" = "ami-0f0f6036a0b22bed3"
    }
    "eu-west-1" = {
      "1TB" = "ami-03c94bc717dedeb99"
      "12TB" = "ami-002cd144ed6ce7b14"
      "96TB" = "ami-09f4852678b52bb13"
      "103TB" = "ami-09c509d919e6760dd"
      "270TB" = "ami-02d86c671f0bd9cca"
      "809TB" = "ami-01a8036d8052fb73c"
      "Custom" = "ami-0137ab8f555c8131e"
    }
    "eu-west-2" = {
      "1TB" = "ami-0347bc44b1f970e59"
      "12TB" = "ami-02ba7f60388a8e5fa"
      "96TB" = "ami-0446cca72af4aa282"
      "103TB" = "ami-066b5e33c677fe999"
      "270TB" = "ami-08e23928b761a13ee"
      "809TB" = "ami-02be75ab6796a9ff8"
      "Custom" = "ami-0ca025728995434a1"
    }
    "eu-west-3" = {
      "1TB" = "ami-02c01514e72adebec"
      "12TB" = "ami-032fd9c2b6286400d"
      "96TB" = "ami-0ef4c26d449775c52"
      "103TB" = "ami-031ce69f9e26ddf37"
      "270TB" = "ami-0cfb3a75c81ceb296"
      "809TB" = "ami-0c9b5b448acc8e766"
      "Custom" = "ami-0650eb171386605ce"
    }
    "eu-north-1" = {
      "1TB" = "ami-06f655d9214936058"
      "12TB" = "ami-07020128b658f0df7"
      "96TB" = "ami-0208a3b017457fc9c"
      "103TB" = "ami-007d81f07fe9c2edc"
      "270TB" = "ami-01fe8898c8e4de3bb"
      "809TB" = "ami-01ead3e8349d4e24e"
      "Custom" = "ami-091ec9ed49c2fa333"
    }
    "eu-south-1" = {
      "1TB" = "ami-02d0c56024017393c"
      "12TB" = "ami-07ad4f9ab7596e574"
      "96TB" = "ami-0f37f6c67670da626"
      "103TB" = "ami-045e3165d6dc77f20"
      "270TB" = "ami-04578356f2917b249"
      "809TB" = "ami-0694cea470d032871"
      "Custom" = "ami-0923b4ce1ff09046d"
    }
    "ap-southeast-1" = {
      "1TB" = "ami-02fbb89634f343d90"
      "12TB" = "ami-01c07ffdb1be78532"
      "96TB" = "ami-0ac8410fb1a2d1b27"
      "103TB" = "ami-05dbc4e5ae0c1fcd1"
      "270TB" = "ami-07d42ad1671aa5e54"
      "809TB" = "ami-0bedf992cf0f93e29"
      "Custom" = "ami-0003f71dd474cc609"
    }
    "ap-southeast-2" = {
      "1TB" = "ami-07f5ef1b0a4b2d4b0"
      "12TB" = "ami-09d41b06127b6ca10"
      "96TB" = "ami-02955f4689d54f9e5"
      "103TB" = "ami-01441301142f76343"
      "270TB" = "ami-0b7657287efa8e356"
      "809TB" = "ami-0136c35459e8469cc"
      "Custom" = "ami-01ce007aa566996f3"
    }
    "ap-south-1" = {
      "1TB" = "ami-0a6f7f19bbf41b0fb"
      "12TB" = "ami-0b07f06f329dc9dbd"
      "96TB" = "ami-0bf61e85199f30b77"
      "103TB" = "ami-09d1698197d17bf83"
      "270TB" = "ami-00529378038b9e378"
      "809TB" = "ami-0eae75fd54e15afe7"
      "Custom" = "ami-07e47d3fcfaa1cea9"
    }
    "ap-northeast-1" = {
      "1TB" = "ami-0bde66f7c006f955f"
      "12TB" = "ami-0e4caa0c7a3f802a2"
      "96TB" = "ami-0971c4d95ba65106b"
      "103TB" = "ami-0e6378f9f4e4384b8"
      "270TB" = "ami-0d8afdd0a53bf4353"
      "809TB" = "ami-01ddb027beedecf4f"
      "Custom" = "ami-08ffbd8a8a2f1cc8a"
    }
    "ap-northeast-2" = {
      "1TB" = "ami-0a44564dc98f349f5"
      "12TB" = "ami-083f0b5fb4d684148"
      "96TB" = "ami-018e2e310328ded75"
      "103TB" = "ami-0e3137fdacf56b255"
      "270TB" = "ami-058493ecc7049f20c"
      "809TB" = "ami-08838d3976c0b4970"
      "Custom" = "ami-0b3e0582fcb643084"
    }
    "ap-east-1" = {
      "1TB" = "ami-08f17a2f202057ed2"
      "12TB" = "ami-06a9a62424792062e"
      "96TB" = "ami-0011f28b76954110b"
      "103TB" = "ami-040f5acf6aa39a0d2"
      "270TB" = "ami-03c6ad18da5ec9a2a"
      "809TB" = "ami-03dd24e92b1fad3fb"
      "Custom" = "ami-0511d4cdb2c1457b5"
    }
    "sa-east-1" = {
      "1TB" = "ami-01e11bea0c97de5f6"
      "12TB" = "ami-0973536676be3e57d"
      "96TB" = "ami-0cdec531b0d26d618"
      "103TB" = "ami-074f00d6380430d63"
      "270TB" = "ami-08e3b094acc8b83d2"
      "809TB" = "ami-0c195ad00c4df3070"
      "Custom" = "ami-0e620bfa90fe6a2d4"
    }
    "me-south-1" = {
      "1TB" = "ami-038b4bc2348353797"
      "12TB" = "ami-03c6d50cc58beaf08"
      "96TB" = "ami-0c13456e00227d07c"
      "103TB" = "ami-0294bd23df867eea2"
      "270TB" = "ami-048281c496813f816"
      "809TB" = "ami-083308b26151a5aab"
      "Custom" = "ami-0203430c4d6fc323b"
    }
    "af-south-1" = {
      "1TB" = "ami-050aa2d3b2d67d1cd"
      "12TB" = "ami-033ce968cabefad01"
      "96TB" = "ami-0f006bdc8f8c8e671"
      "103TB" = "ami-087d85db191cc6b64"
      "270TB" = "ami-0b75a644ffad780d9"
      "809TB" = "ami-02ecd280fca6ea8e2"
      "Custom" = "ami-0e7faebf7d6207a7c"
    }
  }
}

