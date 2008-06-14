describe "mintache store avoiding the dogpile effect" do
  it "should store a second key to keep check of the time" # "#{key}_validity"
  it "should store a third key to keep the data for a longer expiry time" # "#{key}_data"
  it "should use the second and third keys to return the data if the first key has expired"
  it "should return a cache miss when the second level cache is used"
  it "should set a temporary cache when the second level cache is used"
end