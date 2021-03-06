import Images
using Color, FixedPointNumbers, Base.Test

const writedir = joinpath(tempdir(), "Images")

if !isdir(writedir)
    mkdir(writedir)
end

a = rand(2,2)
aa = convert(Array{Ufixed8}, a)
fn = joinpath(writedir, "2by2.png")
Images.imwrite(a, fn)
b = Images.imread(fn)
@test convert(Array, b) == aa
Images.imwrite(aa, fn)
b = Images.imread(fn)
@test convert(Array, b) == aa
aaimg = Images.grayim(aa)
open(fn, "w") do file
    writemime(file, "image/png", aaimg)
end
b = Images.imread(fn)
@test b == aaimg
aa = convert(Array{Ufixed16}, a)
Images.imwrite(aa, fn)
b = Images.imread(fn)
@test convert(Array, b) == aa
aa = Ufixed12[0.6 0.2;
              1.4 0.8]
open(fn, "w") do file
    writemime(file, "image/png", Images.grayim(aa))
end
b = Images.imread(fn)
@test Images.data(b) == Ufixed8[0.6 0.2;
                                1.0 0.8]

# test writemime's use of restrict
abig = Images.grayim(rand(Uint8, 1024, 1023))
fn = joinpath(writedir, "big.png")
open(fn, "w") do file
    writemime(file, "image/png", abig)
end
b = Images.imread(fn)
@test Images.data(b) == convert(Array{Ufixed8,2}, Images.data(Images.restrict(abig, (1,2))))

# More writemime tests
a = Images.colorim(rand(Uint8, 3, 2, 2))
fn = joinpath(writedir, "2by2.png")
open(fn, "w") do file
    writemime(file, "image/png", a)
end
b = Images.imread(fn)
@test Images.data(b) == Images.data(a)

abig = Images.colorim(rand(Uint8, 3, 1021, 1026))
fn = joinpath(writedir, "big.png")
open(fn, "w") do file
    writemime(file, "image/png", abig)
end
b = Images.imread(fn)
@test Images.data(b) == convert(Array{RGB{Ufixed8},2}, Images.data(Images.restrict(abig, (1,2))))

using Color
datafloat = reshape(linspace(0.5, 1.5, 6), 2, 3)
dataint = iround(Uint8, 254*(datafloat .- 0.5) .+ 1)  # ranges from 1 to 255
# build our colormap
b = RGB(0,0,1)
w = RGB(1,1,1)
r = RGB(1,0,0)
cmaprgb = Array(RGB{Float64}, 255)
f = linspace(0,1,128)
cmaprgb[1:128] = [(1-x)*b + x*w for x in f]
cmaprgb[129:end] = [(1-x)*w + x*r for x in f[2:end]]
img = Images.ImageCmap(dataint, cmaprgb)
Images.imwrite(img,joinpath(writedir,"cmap.jpg"))
