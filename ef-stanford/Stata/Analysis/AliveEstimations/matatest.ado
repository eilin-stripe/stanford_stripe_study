program define matatest

    mata: mata clear
    mata: matatest(1, 2)
    * mata: matatestfile(1, 2)
    mata mosave matatest()
    mata: mata mosave matatest()

end

mata:
function matatest(X, Y)
{
    A = X + Y
    return(A)
}
end
