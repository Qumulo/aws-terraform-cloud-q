#MIT License

#Copyright (c) 2022 Qumulo, Inc.

#Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the Software), to deal 
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions =

#The above copyright notice and this permission notice shall be included in all 
#copies or substantial portions of the Software.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
#SOFTWARE.

resource "aws_cloudwatch_log_group" "audit_log" {
  count = var.audit_logging ? 1 : 0

  name = "/qumulo/${var.deployment_unique_name}-audit-log"

  tags = merge(var.tags, { Name = "${var.deployment_unique_name}" })
}

resource "aws_resourcegroups_group" "cluster_rg" {
  name = "Qumulo-Cluster-EC2-${var.deployment_unique_name}"

  resource_query {
    type  = "TAG_FILTERS_1_0"
    query = <<JSON
  {
      "ResourceTypeFilters": [
          "AWS::AllSupported"
      ],
      "TagFilters": [
          {
              "Key":"Name",
              "Values":["${var.node_names}"]
          }
      ]
  }
  JSON
  }

}

resource "aws_resourcegroups_group" "cluster_rg_ssd" {
  name = "Qumulo-Cluster-SSD-${var.deployment_unique_name}"

  resource_query {
    type  = "TAG_FILTERS_1_0"
    query = <<JSON
  {
      "ResourceTypeFilters": [
          "AWS::AllSupported"
      ],
      "TagFilters": [
          {
              "Key":"Name",
              "Values":["${var.deployment_unique_name}-gp2","${var.deployment_unique_name}-gp3"]
          }
      ]
  }
  JSON
  }
}

resource "aws_resourcegroups_group" "cluster_rg_hdd" {
  count = var.all_flash == "AF" ? 0 : 1

  name = "Qumulo-Cluster-HDD-${var.deployment_unique_name}"

  resource_query {
    type  = "TAG_FILTERS_1_0"
    query = <<JSON
  {
      "ResourceTypeFilters": [
          "AWS::AllSupported"
      ],
      "TagFilters": [
          {
              "Key":"Name",
              "Values":["${var.deployment_unique_name}-st1","${var.deployment_unique_name}-sc1"]
          }
      ]
  }
  JSON
  }
}

resource "aws_cloudwatch_dashboard" "cw_dashboard" {
  dashboard_name = "Qumulo-Cluster-${var.deployment_unique_name}"
  dashboard_body = <<EOF
  {
        "widgets": [
            {
                "type": "metric",
                "x": 15,
                "y": 0,
                "width": 9,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "Qumulo/Metrics", "FileSystemFreeCapacity", "ClusterName", "${var.cluster_name}", { "id": "m2" } ]
                    ],
                    "view": "timeSeries",
                    "stacked": false,
                    "region": "${var.aws_region}",
                    "title": "File System Available Capacity",
                    "period": 300,
                    "stat": "Average",
                    "yAxis": {
                        "left": {
                            "label": ""
                        }
                    }
                }
            },
            {
                "type": "metric",
                "x": 9,
                "y": 0,
                "width": 6,
                "height": 3,
                "properties": {
                    "metrics": [
                        [ "Qumulo/Metrics", "RemainingNodeFailures", "ClusterName", "${var.cluster_name}" ]
                    ],
                    "view": "singleValue",
                    "region": "${var.aws_region}",
                    "title": "EC2 Instance Protection",
                    "period": 300,
                    "stat": "Minimum"
                }
            },
            {
                "type": "metric",
                "x": 0,
                "y": 0,
                "width": 9,
                "height": 3,
                "properties": {
                    "metrics": [
                        [ "Qumulo/Metrics", "TotalNodeCount", "ClusterName", "${var.cluster_name}" ],
                        [ ".", "HealthyNodeCount", ".", "." ]
                    ],
                    "view": "singleValue",
                    "region": "${var.aws_region}",
                    "title": "Cluster EC2 Instances",
                    "period": 300,
                    "stat": "Minimum"
                }
            },
            {
                "type": "metric",
                "x": 0,
                "y": 3,
                "width": 9,
                "height": 3,
                "properties": {
                    "metrics": [
                        [ "Qumulo/Metrics", "FailedDriveCount", "ClusterName", "${var.cluster_name}" ]
                    ],
                    "view": "singleValue",
                    "region": "${var.aws_region}",
                    "title": "Failed EBS Volumes",
                    "period": 300,
                    "stat": "Maximum"
                }
            },
            {
                "type": "metric",
                "x": 9,
                "y": 3,
                "width": 6,
                "height": 3,
                "properties": {
                    "metrics": [
                        [ "Qumulo/Metrics", "RemainingDriveFailures", "ClusterName", "${var.cluster_name}" ]
                    ],
                    "view": "singleValue",
                    "region": "${var.aws_region}",
                    "title": "EBS Volume Protection",
                    "period": 300,
                    "stat": "Minimum"
                }
            },
            {
                "type": "metric",
                "x": 0,
                "y": 6,
                "width": 9,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "Qumulo/Metrics", "ProtocolReadThroughput", "ClusterName", "${var.cluster_name}" ],
                        [ ".", "ProtocolWriteThroughput", ".", "." ]
                    ],
                    "view": "timeSeries",
                    "stacked": false,
                    "region": "${var.aws_region}",
                    "title": "Protocol Throughput",
                    "period": 60,
                    "stat": "Average"
                }
            },
            {
                "type": "metric",
                "x": 15,
                "y": 6,
                "width": 9,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "Qumulo/Metrics", "ProtocolReadLatency", "ClusterName", "${var.cluster_name}" ],
                        [ ".", "ProtocolWriteLatency", ".", "." ],
                        [ ".", "ProtocolMetadataLatency", ".", "." ]
                    ],
                    "view": "timeSeries",
                    "stacked": false,
                    "region": "${var.aws_region}",
                    "title": "Protocol Latency",
                    "period": 60,
                    "stat": "Average"
                }
            },
            {
                "type": "metric",
                "x": 9,
                "y": 6,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "Qumulo/Metrics", "ProtocolReadOps", "ClusterName", "${var.cluster_name}" ],
                        [ ".", "ProtocolWriteOps", ".", "." ]
                    ],
                    "view": "timeSeries",
                    "stacked": false,
                    "region": "${var.aws_region}",
                    "title": "Protocol IOPS",
                    "period": 60,
                    "stat": "Average"
                }
            }
        ]


  }
  EOF
}