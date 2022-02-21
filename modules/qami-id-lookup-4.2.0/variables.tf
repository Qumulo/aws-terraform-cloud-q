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
      "1TB"    = "ami-0de3b8398d0b4682b"
      "12TB"   = "ami-077acd602798fc77e"
      "96TB"   = "ami-01ea2b72b65e23180"
      "103TB"  = "ami-0f24551d158762022"
      "270TB"  = "ami-0b40460c3ba7ed040"
      "809TB"  = "ami-011b2ed7629dab57f"
      "Custom" = "ami-018f68f1ba18cfae6"
    }
    "us-east-2" = {
      "1TB"    = "ami-057a9a612ccb5a565"
      "12TB"   = "ami-0099d82b5478ac3a8"
      "96TB"   = "ami-0536998492680cd99"
      "103TB"  = "ami-0f4df3b01c92d3e1f"
      "270TB"  = "ami-0592ba2d92da8f7bc"
      "809TB"  = "ami-0c8b70de86ef045cc"
      "Custom" = "ami-0af5e5a52d4d1daab"
    }
    "us-west-1" = {
      "1TB"    = "ami-031f283cca36f30a4"
      "12TB"   = "ami-092cfa109507c9b60"
      "96TB"   = "ami-0c8452b67a56f8806"
      "103TB"  = "ami-0f2e318693ee095b6"
      "270TB"  = "ami-0916af006fa6fd2c8"
      "809TB"  = "ami-018890474f475efd2"
      "Custom" = "ami-0eca897c4f3bcd563"
    }
    "us-west-2" = {
      "1TB"    = "ami-035468e50fe644620"
      "12TB"   = "ami-01e02781c4077b271"
      "96TB"   = "ami-043024e17d87b99b2"
      "103TB"  = "ami-0d3e0acb5420484e4"
      "270TB"  = "ami-07607a89986511baa"
      "809TB"  = "ami-054ea5e758e334c59"
      "Custom" = "ami-082ee84fdc0b590d8"
    }
    "us-gov-west-1" = {
      "1TB"    = "ami-0c3515c3db37588ea"
      "12TB"   = "ami-0b15b99c977ebae7e"
      "96TB"   = "ami-09dd7cb9542e3b605"
      "103TB"  = "ami-076579991b4ee6b5e"
      "270TB"  = "ami-0dd504079750358f2"
      "809TB"  = "ami-056db12044259d7d6"
      "Custom" = "ami-00e93ab22f70e8a47"
    }
    "us-gov-east-1" = {
      "1TB"    = "ami-00710f6e2c2911ff2"
      "12TB"   = "ami-005efb68076cfca72"
      "96TB"   = "ami-0ebf78406ec90a5e9"
      "103TB"  = "ami-0903f48b62a224d71"
      "270TB"  = "ami-02af899a984183339"
      "809TB"  = "ami-0664c809a88f22533"
      "Custom" = "ami-08f3bfd86b9e84ca7"
    }
    "ca-central-1" = {
      "1TB"    = "ami-0dd28c59779d4bd85"
      "12TB"   = "ami-07db1f322a0dd38bf"
      "96TB"   = "ami-0f9a6582b2a068cf8"
      "103TB"  = "ami-0bc1069df739ea618"
      "270TB"  = "ami-0539d57ec271c8150"
      "809TB"  = "ami-01d5eae06713a06bd"
      "Custom" = "ami-0eb47352b04995778"
    }
    "eu-central-1" = {
      "1TB"    = "ami-004535fd3c0bcc88a"
      "12TB"   = "ami-0f2e1a56f47205fad"
      "96TB"   = "ami-09a8f6c323391cbc6"
      "103TB"  = "ami-0b02bb849b9211982"
      "270TB"  = "ami-014f5f6eaf72b1113"
      "809TB"  = "ami-09040b53ec35b58ac"
      "Custom" = "ami-050194b1f0a846026"
    }
    "eu-west-1" = {
      "1TB"    = "ami-044b541c3a25f22b2"
      "12TB"   = "ami-06501a7623841054a"
      "96TB"   = "ami-0a38ef5e9e0924afa"
      "103TB"  = "ami-0c29bc1445525da71"
      "270TB"  = "ami-0cfba9d390ebe9d25"
      "809TB"  = "ami-0ffc3f293e05364f9"
      "Custom" = "ami-0176727a87edbc895"
    }
    "eu-west-2" = {
      "1TB"    = "ami-0296b4e16c46ea84a"
      "12TB"   = "ami-07693f0b7017f1465"
      "96TB"   = "ami-09379ffd63b8df384"
      "103TB"  = "ami-03b236a5a2faa7a76"
      "270TB"  = "ami-00f35648b611d1fc3"
      "809TB"  = "ami-0c0109f9691bfabf5"
      "Custom" = "ami-05238226c7f3bdfc6"
    }
    "eu-west-3" = {
      "1TB"    = "ami-0ebb8a78d849805df"
      "12TB"   = "ami-0c10ff31c3d56bfd1"
      "96TB"   = "ami-0de34cb319dd443dc"
      "103TB"  = "ami-0bf704d8e155d9acb"
      "270TB"  = "ami-03943e0481ee0e849"
      "809TB"  = "ami-0b6be773a30e21c26"
      "Custom" = "ami-0cd6b01be0d3288d9"
    }
    "eu-north-1" = {
      "1TB"    = "ami-025f6d41d8e1be964"
      "12TB"   = "ami-07da0faea766285ab"
      "96TB"   = "ami-06a51e8bfe81c9882"
      "103TB"  = "ami-0002984d1af28442e"
      "270TB"  = "ami-0d91e4f7f5904d630"
      "809TB"  = "ami-012bd25f7468d2684"
      "Custom" = "ami-0fbc5783538a12873"
    }
    "eu-south-1" = {
      "1TB"    = "ami-07be33d2f9900f476"
      "12TB"   = "ami-0a8a113680aea86bb"
      "96TB"   = "ami-0f21c0b67bb6412de"
      "103TB"  = "ami-011a2fa21a3aa2495"
      "270TB"  = "ami-0731a07eccb6df96b"
      "809TB"  = "ami-01dccbbd4131d3921"
      "Custom" = "ami-0df874cb592ac56b9"
    }
    "ap-southeast-1" = {
      "1TB"    = "ami-04e893620ce6791cc"
      "12TB"   = "ami-05de76f47706a8f4e"
      "96TB"   = "ami-09458a6b3776f1e2d"
      "103TB"  = "ami-0c80f51280a1c2cc0"
      "270TB"  = "ami-09c7656428c8a1291"
      "809TB"  = "ami-08305e680a1ab4c9a"
      "Custom" = "ami-0aa3fad26e5afe82a"
    }
    "ap-southeast-2" = {
      "1TB"    = "ami-08b3f70ff8cd428c2"
      "12TB"   = "ami-0f20efcaa00ee2738"
      "96TB"   = "ami-04ae14b1cef2da570"
      "103TB"  = "ami-0f5687839b4c396b6"
      "270TB"  = "ami-00ca0bdf2278cf110"
      "809TB"  = "ami-0e7d4599e1db72e08"
      "Custom" = "ami-0bd9e73f1f1fba955"
    }
    "ap-south-1" = {
      "1TB"    = "ami-0ccb40b862736206e"
      "12TB"   = "ami-0abb3978e9a20cdc6"
      "96TB"   = "ami-08ccb5eb8c5397c54"
      "103TB"  = "ami-03a609e18047253c2"
      "270TB"  = "ami-0b7d092ef45b115cc"
      "809TB"  = "ami-00a1aa8a92f381d4a"
      "Custom" = "ami-0abb6ae7f7ba82a28"
    }
    "ap-northeast-1" = {
      "1TB"    = "ami-0ced47d87df5b3a42"
      "12TB"   = "ami-09f49f11ea0372500"
      "96TB"   = "ami-074e48bf084e1797e"
      "103TB"  = "ami-0cbbe5eed9d7be2b0"
      "270TB"  = "ami-054b1d95bc3c75eb4"
      "809TB"  = "ami-0472fd5c9ed3ab87f"
      "Custom" = "ami-0433c1d19f8c1e358"
    }
    "ap-northeast-2" = {
      "1TB"    = "ami-033c1737c1e243ecd"
      "12TB"   = "ami-075caac55b16264cb"
      "96TB"   = "ami-027731fbfea596bbc"
      "103TB"  = "ami-04a045aeb5ff240e2"
      "270TB"  = "ami-0fac7a81caa728d63"
      "809TB"  = "ami-00006e40990f1a194"
      "Custom" = "ami-09d2f7e4d83f4795c"
    }
    "ap-east-1" = {
      "1TB"    = "ami-00ceed6f3fb8c1d99"
      "12TB"   = "ami-0f95089db128afbbd"
      "96TB"   = "ami-0a382c844e3330e03"
      "103TB"  = "ami-037105c161c007200"
      "270TB"  = "ami-0036bee5042b5b9cd"
      "809TB"  = "ami-05c3dfe82071633f1"
      "Custom" = "ami-0a51d5955d12ba5e4"
    }
    "sa-east-1" = {
      "1TB"    = "ami-0b05c49f74a4cf292"
      "12TB"   = "ami-094d1566d65c3780b"
      "96TB"   = "ami-0c49a9f545262ca25"
      "103TB"  = "ami-03a353b0eeaf743fd"
      "270TB"  = "ami-05816852419af5bb3"
      "809TB"  = "ami-074fcf744a276acf5"
      "Custom" = "ami-081f5244fbb6140c8"
    }
    "me-south-1" = {
      "1TB"    = "ami-05ab00b8a1a262137"
      "12TB"   = "ami-0d3e0b1cf30993bf4"
      "96TB"   = "ami-0e5615d1566beafe7"
      "103TB"  = "ami-09eeb0f9c77e17e32"
      "270TB"  = "ami-062089bd4fd6d8ea5"
      "809TB"  = "ami-00da7ba20f3fc50c0"
      "Custom" = "ami-086494e6325c4890a"
    }
    "af-south-1" = {
      "1TB"    = "ami-076e8774933546bc8"
      "12TB"   = "ami-05a7fe2f132a352f7"
      "96TB"   = "ami-0648a5763bd8512de"
      "103TB"  = "ami-0c3b37d5ce3c6681b"
      "270TB"  = "ami-0edda8dee6696db25"
      "809TB"  = "ami-0356fb80048e45c63"
      "Custom" = "ami-015e0d20566202c88"
    }
  }
}

