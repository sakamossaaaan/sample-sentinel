import "tfplan/v2" as tfplan

# 使用可能なインスタンスタイプのリスト
allowed_types = ["t2.large"]

# すべてのEC2インスタンスをフィルタリング
ec2_instances = filter tfplan.resource_changes as _, rc {
    rc.type is "aws_instance" and
    (rc.change.actions contains "create" or rc.change.actions is ["update"])
}

# ルール：インスタンスタイプが許可リストに含まれていること
instance_type_allowed = rule {
    all ec2_instances as _, instance {
        instance.change.after.instance_type in allowed_types
    }
}

# ルール：必須タグが存在すること
required_tags_present = rule {
    all ec2_instances as _, instance {
        keys(instance.change.after.tags) contains "Environment" and
        keys(instance.change.after.tags) contains "Project"
    }
}

# メインルール
main = rule {
    instance_type_allowed and
    required_tags_present
}
