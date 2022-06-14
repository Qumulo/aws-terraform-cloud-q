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
      "1TB"    = "ami-09ce56773b88ce776"
      "12TB"   = "ami-0ec75ac7c296478d8"
      "96TB"   = "ami-0b8d20bfe2262f5bd"
      "103TB"  = "ami-0450d07b8c79c8a3d"
      "270TB"  = "ami-08234d1ec17c1c9e3"
      "809TB"  = "ami-0d69f5f25c94a22b3"
      "Custom" = "ami-0cd5b31f05676eec5"
    }
    "us-east-2" = {
      "1TB"    = "ami-0ea771ba63cd7d86a"
      "12TB"   = "ami-01fe03c34ac750940"
      "96TB"   = "ami-06d511dcb75cb79dd"
      "103TB"  = "ami-068b54a8361c23f09"
      "270TB"  = "ami-0ef1a6cb419f5a9d6"
      "809TB"  = "ami-0084ce3903090bd02"
      "Custom" = "ami-0bd6ceba3a380bed5"
    }
    "us-west-1" = {
      "1TB"    = "ami-03546125cdd33bc67"
      "12TB"   = "ami-0e2ddc39f90176bd0"
      "96TB"   = "ami-0a7d632e99e5c7f4d"
      "103TB"  = "ami-0bc064d43f967e306"
      "270TB"  = "ami-045613d7967043d97"
      "809TB"  = "ami-0777ae1abc6ee25ad"
      "Custom" = "ami-05689c2411bac356d"
    }
    "us-west-2" = {
      "1TB"    = "ami-0253ce53ad0349cfd"
      "12TB"   = "ami-0ff4946d9ae4d46b1"
      "96TB"   = "ami-0a5a62d74ec10d997"
      "103TB"  = "ami-034f1d2fe9ee5eac9"
      "270TB"  = "ami-06a0584fa1647a8b7"
      "809TB"  = "ami-00a82d869c293dc13"
      "Custom" = "ami-0cf066b8367198360"
    }
    "us-gov-west-1" = {
      "1TB"    = "ami-071f99eb1c0e9dcbe"
      "12TB"   = "ami-0da5f397ecfb13efb"
      "96TB"   = "ami-02028fb85a42e8f67"
      "103TB"  = "ami-052fb5997ffbb8c02"
      "270TB"  = "ami-00724a7c2377ea9d0"
      "809TB"  = "ami-0130466231049214c"
      "Custom" = "ami-0062b611fa604c3d3"
    }
    "us-gov-east-1" = {
      "1TB"    = "ami-02bab1aa3b37d0043"
      "12TB"   = "ami-06636cbde882e9f5c"
      "96TB"   = "ami-02d1e586319c3d017"
      "103TB"  = "ami-083d29be17c678601"
      "270TB"  = "ami-0f84e14dec9585f7a"
      "809TB"  = "ami-0ef8aae93f85cf2ac"
      "Custom" = "ami-03e42b166fdc15b60"
    }
    "ca-central-1" = {
      "1TB"    = "ami-03da16801edd75012"
      "12TB"   = "ami-096675284c00c0292"
      "96TB"   = "ami-06cd05693aed42df9"
      "103TB"  = "ami-068491f7c999c73db"
      "270TB"  = "ami-01a719e44f604e4cc"
      "809TB"  = "ami-0b6ab4531373ad95d"
      "Custom" = "ami-05e6cfc67a150a16c"
    }
    "eu-central-1" = {
      "1TB"    = "ami-05f293f803602b1bc"
      "12TB"   = "ami-0fe3cb596d0752fb7"
      "96TB"   = "ami-02091965305409347"
      "103TB"  = "ami-0e1c641144993fe38"
      "270TB"  = "ami-05dbf5f1de16a8f13"
      "809TB"  = "ami-0336d684e4b620b72"
      "Custom" = "ami-04ee059f83f864f8b"
    }
    "eu-west-1" = {
      "1TB"    = "ami-02b731012cfcf1241"
      "12TB"   = "ami-0ddb9a08395a10ab8"
      "96TB"   = "ami-043a7db0ed2ae2c2f"
      "103TB"  = "ami-0b43b3fb2f2bbbaf7"
      "270TB"  = "ami-0db89cc318d245e41"
      "809TB"  = "ami-076949a60a29162f0"
      "Custom" = "ami-0baa54b1207ade1a9"
    }
    "eu-west-2" = {
      "1TB"    = "ami-09a8559e53dc90139"
      "12TB"   = "ami-0b9c1ded8edf30b10"
      "96TB"   = "ami-0e74bb19abf9113eb"
      "103TB"  = "ami-0d11a3f27bda84e62"
      "270TB"  = "ami-0d3b1a2f86b80ff7f"
      "809TB"  = "ami-0fda268f3cfa8ffb9"
      "Custom" = "ami-0207022ca39079f05"
    }
    "eu-west-3" = {
      "1TB"    = "ami-078adb7c9a502111a"
      "12TB"   = "ami-0b446245cf2809b8a"
      "96TB"   = "ami-018ad8e2b3b0a2081"
      "103TB"  = "ami-02685e8f0ab640afa"
      "270TB"  = "ami-08b1ab4c1c7bf8a62"
      "809TB"  = "ami-0795f6c152aac6f8f"
      "Custom" = "ami-0b224bd915288d55f"
    }
    "eu-north-1" = {
      "1TB"    = "ami-03da6f31a08111c30"
      "12TB"   = "ami-05eb3e1a38433f651"
      "96TB"   = "ami-001ac171feba97584"
      "103TB"  = "ami-04e24b1c5905f590b"
      "270TB"  = "ami-021e46fe6d02401e6"
      "809TB"  = "ami-015908ed5bf338079"
      "Custom" = "ami-06f7e931fcdafb956"
    }
    "eu-south-1" = {
      "1TB"    = "ami-0d4f124ff92384795"
      "12TB"   = "ami-02e0683a27dd7a801"
      "96TB"   = "ami-03460c53e777aadd6"
      "103TB"  = "ami-07c19d1606872b0b0"
      "270TB"  = "ami-0632815f6a8fdba2e"
      "809TB"  = "ami-00e227bac92e776e2"
      "Custom" = "ami-0445c36d1ed22cf99"
    }
    "ap-southeast-1" = {
      "1TB"    = "ami-0a35cab633f211d49"
      "12TB"   = "ami-0879c5e5091b58c61"
      "96TB"   = "ami-057e35a8b437fdf43"
      "103TB"  = "ami-04353c98f7cd1ed34"
      "270TB"  = "ami-01e82e3118342da8e"
      "809TB"  = "ami-0a301403c03860b1e"
      "Custom" = "ami-0297e84a9c8afcc35"
    }
    "ap-southeast-2" = {
      "1TB"    = "ami-03055e0f14f322f5a"
      "12TB"   = "ami-085992b4f44261731"
      "96TB"   = "ami-0d5e74f12b19a6cd3"
      "103TB"  = "ami-0bb72819079f3dd68"
      "270TB"  = "ami-0c961abab0a227fd5"
      "809TB"  = "ami-0164a1a840642427d"
      "Custom" = "ami-00e02477827fb608b"
    }
    "ap-south-1" = {
      "1TB"    = "ami-0fbc447719c25c90d"
      "12TB"   = "ami-0f767d22b62246bf6"
      "96TB"   = "ami-059790ea0a06e6ba7"
      "103TB"  = "ami-02e86489bc4cbef64"
      "270TB"  = "ami-08b88b673ffdec8a4"
      "809TB"  = "ami-039d6ae3bbea1d557"
      "Custom" = "ami-05718f770481c6aa7"
    }
    "ap-northeast-1" = {
      "1TB"    = "ami-0ccd798be2ac96ebf"
      "12TB"   = "ami-04c499cb55dcf6c01"
      "96TB"   = "ami-00f619ecb93708f4c"
      "103TB"  = "ami-00202a421469cbb4e"
      "270TB"  = "ami-0682848d210dea4a1"
      "809TB"  = "ami-0e28580c6445e228c"
      "Custom" = "ami-0635e2676771e7d9d"
    }
    "ap-northeast-2" = {
      "1TB"    = "ami-0a8cddf7235ed9814"
      "12TB"   = "ami-0fd19b4e5bcd97ee1"
      "96TB"   = "ami-0dab02a14d128324d"
      "103TB"  = "ami-0f7fab5efbbe3bfd9"
      "270TB"  = "ami-09fb354892f90ef17"
      "809TB"  = "ami-09e4e721f4dcf09e2"
      "Custom" = "ami-082abe17f905ea817"
    }
    "ap-east-1" = {
      "1TB"    = "ami-0ec73bc713d978f26"
      "12TB"   = "ami-0e9adefc6aa755214"
      "96TB"   = "ami-0eb472ded50ee935e"
      "103TB"  = "ami-016baacae81990aa9"
      "270TB"  = "ami-0953314c89c341e0e"
      "809TB"  = "ami-064f1f364ad5a8dda"
      "Custom" = "ami-02cb34115f6295217"
    }
    "sa-east-1" = {
      "1TB"    = "ami-06e73ee02f88d8552"
      "12TB"   = "ami-002d7a5f52e2785fd"
      "96TB"   = "ami-0723b87084d0b17c0"
      "103TB"  = "ami-01d274ad224971409"
      "270TB"  = "ami-0a05815988c2a6403"
      "809TB"  = "ami-02727dc405fb0fcdb"
      "Custom" = "ami-057b4c65ff79369ec"
    }
    "me-south-1" = {
      "1TB"    = "ami-08245d8cf1b067547"
      "12TB"   = "ami-03748e1331933a6b4"
      "96TB"   = "ami-0bae0bdaac033f29d"
      "103TB"  = "ami-006f12a1f8595b4f9"
      "270TB"  = "ami-0b27578b168c00a01"
      "809TB"  = "ami-03fc2ce6f878a9e93"
      "Custom" = "ami-0d9a58e33cffbb223"
    }
    "af-south-1" = {
      "1TB"    = "ami-0bcbb2dc20fc7319b"
      "12TB"   = "ami-0093fe33e9db902b2"
      "96TB"   = "ami-0db5391409aea168a"
      "103TB"  = "ami-0bfe2f2d1c36b323c"
      "270TB"  = "ami-0335991b05e6fc09f"
      "809TB"  = "ami-052527eb2c9c1423c"
      "Custom" = "ami-06c5c11cefff56ee1"
    }
  }
}

