#MIT License

#Copyright (c) 2022 Qumulo, Inc.

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
  type        = string
}
variable "marketplace_short_name" {
  description = "Qumulo AWS marketplace type abbreviated"
  type        = string
}

variable "region_map" {
  description = "Qumulo AMI-IDs mapped to marketplace type and region"
  default = {
    "us-east-1" = {
      "1TB"    = "ami-0c14aa88062fe6435"
      "12TB"   = "ami-0ac1d95c5df4dec2d"
      "96TB"   = "ami-0d114cac392967ebf"
      "103TB"  = "ami-0f6607456984c80fd"
      "270TB"  = "ami-0e6cd449d8209b9d7"
      "809TB"  = "ami-0c156ebadf2059666"
      "Custom" = "ami-018b8d24f5c8148e2"
    }
    "us-east-2" = {
      "1TB"    = "ami-0d8a39f946246384c"
      "12TB"   = "ami-0ce9d852bc5637f12"
      "96TB"   = "ami-0468ff4819bf0d3a8"
      "103TB"  = "ami-06c9da0aba8796070"
      "270TB"  = "ami-07dc498e254f73428"
      "809TB"  = "ami-0678021d3b8d4d065"
      "Custom" = "ami-09363b6136bb677a6"
    }
    "us-west-1" = {
      "1TB"    = "ami-0d6d811515ebf7219"
      "12TB"   = "ami-0cbfc7342b09ab8c5"
      "96TB"   = "ami-0580569090bacbd0d"
      "103TB"  = "ami-0227206615a99104d"
      "270TB"  = "ami-05814b1daff62535e"
      "809TB"  = "ami-0c3272fe565d5a99a"
      "Custom" = "ami-055ad7ef613d7f41a"
    }
    "us-west-2" = {
      "1TB"    = "ami-0df4d523885a06ad2"
      "12TB"   = "ami-02c9d583f4679ca63"
      "96TB"   = "ami-07c3fb50275e856fc"
      "103TB"  = "ami-03c0b53966519210f"
      "270TB"  = "ami-0007ebc0e46fd5022"
      "809TB"  = "ami-0e21ec6b9f2da2f5f"
      "Custom" = "ami-0d3f3b1c9e954c263"
    }
    "us-gov-west-1" = {
      "1TB"    = "ami-05ff62b96f6eb0eae"
      "12TB"   = "ami-0e3f94e48aed998c7"
      "96TB"   = "ami-06b1a8297fa579f95"
      "103TB"  = "ami-0b4f69b1fba0243d1"
      "270TB"  = "ami-0f57b80b304b657f9"
      "809TB"  = "ami-027fcfa64a35d30f5"
      "Custom" = "ami-05eb72897c1e0264a"
    }
    "us-gov-east-1" = {
      "1TB"    = "ami-020d221e715b60f6b"
      "12TB"   = "ami-0123c26a0427f7afb"
      "96TB"   = "ami-04691054ad7b1d60e"
      "103TB"  = "ami-045d9d7e6f5240f54"
      "270TB"  = "ami-0d37f4d4749663ffb"
      "809TB"  = "ami-07cbf4326426b3816"
      "Custom" = "ami-0f9ff0b76462939dd"
    }
    "ca-central-1" = {
      "1TB"    = "ami-0226762e7343d64f6"
      "12TB"   = "ami-0bbf5e48b0718efb4"
      "96TB"   = "ami-0e18978318c7970f1"
      "103TB"  = "ami-006dbac9338cb0809"
      "270TB"  = "ami-08cbab9fe08dcb1db"
      "809TB"  = "ami-002ee4d284fee7f41"
      "Custom" = "ami-0a2034d1c102f4a38"
    }
    "eu-central-1" = {
      "1TB"    = "ami-0e9c90385676e6f84"
      "12TB"   = "ami-05aa673b1b45963d7"
      "96TB"   = "ami-0d1ec1a827f576c63"
      "103TB"  = "ami-0b8cdb092996e8a7c"
      "270TB"  = "ami-05c5fb80383b86357"
      "809TB"  = "ami-0de5b70ed90306fa7"
      "Custom" = "ami-02df917863cdb898f"
    }
    "eu-west-1" = {
      "1TB"    = "ami-022465cfab3ad194c"
      "12TB"   = "ami-0229948b65d602d26"
      "96TB"   = "ami-08d1cb83f16b090f9"
      "103TB"  = "ami-0fc18460fac8ecdb5"
      "270TB"  = "ami-04620d0d0d0555b33"
      "809TB"  = "ami-085d0d84925a33b51"
      "Custom" = "ami-0f5ab890cdcd6c74e"
    }
    "eu-west-2" = {
      "1TB"    = "ami-02c3f93964b558372"
      "12TB"   = "ami-05c397d51b796227d"
      "96TB"   = "ami-072e2c0c8b6d7d499"
      "103TB"  = "ami-00ef88fc5fdea0b8b"
      "270TB"  = "ami-05b943698661b6772"
      "809TB"  = "ami-0aca14332a3c0abf4"
      "Custom" = "ami-0b2094b83c8d7abbc"
    }
    "eu-west-3" = {
      "1TB"    = "ami-0d17579e38daa4a32"
      "12TB"   = "ami-0b5f1f44ddab0981a"
      "96TB"   = "ami-0cd503564da25e659"
      "103TB"  = "ami-0e93acd969ff7d121"
      "270TB"  = "ami-0810a806033200dc9"
      "809TB"  = "ami-0f9f8024aced89028"
      "Custom" = "ami-0a8b1d62fc71584bf"
    }
    "eu-north-1" = {
      "1TB"    = "ami-0ec802974dccd676c"
      "12TB"   = "ami-0a98564d03b22e0e9"
      "96TB"   = "ami-0a03a971cf96dea0b"
      "103TB"  = "ami-0c3011d8b74baf667"
      "270TB"  = "ami-0525dd66cfa561112"
      "809TB"  = "ami-08cec069dc6f27f1d"
      "Custom" = "ami-0e780c7f44cfe360d"
    }
    "eu-south-1" = {
      "1TB"    = "ami-019ff30debe31ba9d"
      "12TB"   = "ami-0bc09301a652fe5ba"
      "96TB"   = "ami-0e100664f399b79d1"
      "103TB"  = "ami-0a465bdfa73c457e6"
      "270TB"  = "ami-0ba1c3f4d1e1c3d81"
      "809TB"  = "ami-0d85714f66f8e8d08"
      "Custom" = "ami-069beeddb2a31ee19"
    }
    "ap-southeast-1" = {
      "1TB"    = "ami-0c70146063ecf8bf4"
      "12TB"   = "ami-021b6082f56d08808"
      "96TB"   = "ami-03926b5a6dabf7768"
      "103TB"  = "ami-0ee39b3b4ba6d9bdc"
      "270TB"  = "ami-0a3205a8d463af427"
      "809TB"  = "ami-07c7a6c1cacc3fc39"
      "Custom" = "ami-010fa108b5b6a39d0"
    }
    "ap-southeast-2" = {
      "1TB"    = "ami-05c109f02369c0a85"
      "12TB"   = "ami-09c177b6e8f6f1f14"
      "96TB"   = "ami-0c72cecff4a0a58c5"
      "103TB"  = "ami-0ac86f08a1269bb46"
      "270TB"  = "ami-09b9012733b259dd7"
      "809TB"  = "ami-0efe231c4d69058bf"
      "Custom" = "ami-0dfe925e305bc7f0b"
    }
    "ap-south-1" = {
      "1TB"    = "ami-068f13600efac9c4d"
      "12TB"   = "ami-030612690d86e9caf"
      "96TB"   = "ami-0bda8847746c2ae82"
      "103TB"  = "ami-0026596135ac6159e"
      "270TB"  = "ami-03afd2c9cffcf8af8"
      "809TB"  = "ami-0f93e89d7cde64093"
      "Custom" = "ami-0d672054c2f301c88"
    }
    "ap-northeast-1" = {
      "1TB"    = "ami-09b7ae8da4834c9fc"
      "12TB"   = "ami-0eb090ae3243b90e8"
      "96TB"   = "ami-0a07fd1d6d45d9367"
      "103TB"  = "ami-005b02a1656d6132f"
      "270TB"  = "ami-0dc5fa548b1fc939b"
      "809TB"  = "ami-0053aae212b8ff814"
      "Custom" = "ami-002a146d8a975906e"
    }
    "ap-northeast-2" = {
      "1TB"    = "ami-0dd7d0ea2b62e68a7"
      "12TB"   = "ami-021f2cb33257de6ec"
      "96TB"   = "ami-0f869764e9a39eb48"
      "103TB"  = "ami-0356fdc8738188bc6"
      "270TB"  = "ami-09c528fc17a93860a"
      "809TB"  = "ami-0700450f9d48c3ac0"
      "Custom" = "ami-0ca1070fcc45c0459"
    }
    "ap-east-1" = {
      "1TB"    = "ami-0debb1316d7efc526"
      "12TB"   = "ami-0e9240c9ab6b4da87"
      "96TB"   = "ami-00eda62f2313293c1"
      "103TB"  = "ami-00651a1863cbc9ee3"
      "270TB"  = "ami-00659ee855cf339ec"
      "809TB"  = "ami-0a2716d21118b5461"
      "Custom" = "ami-045ffdf81bfbd2936"
    }
    "sa-east-1" = {
      "1TB"    = "ami-041cae919d385ef83"
      "12TB"   = "ami-0fbc365849823c05e"
      "96TB"   = "ami-0cec367708e63389f"
      "103TB"  = "ami-0d4e77d4ee8a8644b"
      "270TB"  = "ami-0cafa86773067e31d"
      "809TB"  = "ami-07df87f15ff9fb7aa"
      "Custom" = "ami-031e7e108175094db"
    }
    "me-south-1" = {
      "1TB"    = "ami-005000d40a530adb3"
      "12TB"   = "ami-0aa6a740c39d9506c"
      "96TB"   = "ami-0e587fc4e8de83acc"
      "103TB"  = "ami-01b5d03d4ab656fa1"
      "270TB"  = "ami-00e4fdd0472076eb6"
      "809TB"  = "ami-09e278f790ff10e63"
      "Custom" = "ami-0ee83d789df4843dd"
    }
  }
}

