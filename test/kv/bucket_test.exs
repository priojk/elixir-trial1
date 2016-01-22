defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
      {:ok, bucket} = KV.Bucket.start_link
      {:ok, bucket: bucket} # add it to test context (map)
  end

  test "stores values by key", %{bucket: bucket} do # bucket from test context map
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3

    assert KV.Bucket.delete(bucket, "milk") == 3
    assert KV.Bucket.get(bucket, "milk") == nil
  end
end
