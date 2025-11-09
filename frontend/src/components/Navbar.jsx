import { Link, useLocation } from 'react-router-dom'

const Navbar = () => {
  const location = useLocation()
  const vendorId = localStorage.getItem('vendorId')

  const isActive = (path) => {
    return location.pathname === path
  }

  return (
    <nav style={{
      background: 'rgba(255, 255, 255, 0.05)',
      backdropFilter: 'blur(30px) saturate(200%)',
      WebkitBackdropFilter: 'blur(30px) saturate(200%)',
      borderBottom: '1px solid rgba(255, 255, 255, 0.2)',
      boxShadow: '0 8px 32px rgba(0, 0, 0, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.1)',
      position: 'sticky',
      top: 0,
      zIndex: 50
    }}>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          <div className="flex items-center">
            <Link to="/" className="flex-shrink-0 flex items-center group">
              <span className="font-bold transform group-hover:scale-105 transition-transform" style={{
                fontSize: '20px',
                color: 'white',
                fontFamily: 'Poppins, Inter, system-ui, sans-serif',
                textShadow: '0 2px 10px rgba(0, 0, 0, 0.3)'
              }}>
                Goldman Sachs
              </span>
              <span className="ml-2 hidden sm:block" style={{
                fontSize: '14px',
                color: 'rgba(255, 255, 255, 0.8)'
              }}>
                Vendor Onboarding Hub
              </span>
            </Link>
          </div>

          <div className="flex items-center space-x-2">
            <Link
              to="/"
              className="px-4 py-2 font-medium transition-all duration-200 transform hover:scale-105"
              style={{
                borderRadius: '8px',
                fontSize: '14px',
                color: 'white',
                background: isActive('/') ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
                fontWeight: isActive('/') ? 600 : 500,
                backdropFilter: isActive('/') ? 'blur(10px)' : 'none',
                border: isActive('/') ? '1px solid rgba(255, 255, 255, 0.3)' : '1px solid transparent',
                boxShadow: isActive('/') ? '0 4px 15px rgba(74, 144, 226, 0.3)' : 'none'
              }}
            >
              Home
            </Link>

            {!vendorId && (
              <Link
                to="/register"
                className="px-4 py-2 font-medium transition-all duration-200 transform hover:scale-105"
                style={{
                  borderRadius: '8px',
                  fontSize: '14px',
                  color: 'white',
                  background: isActive('/register') ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
                  fontWeight: isActive('/register') ? 600 : 500,
                  backdropFilter: isActive('/register') ? 'blur(10px)' : 'none',
                  border: isActive('/register') ? '1px solid rgba(255, 255, 255, 0.3)' : '1px solid transparent',
                  boxShadow: isActive('/register') ? '0 4px 15px rgba(74, 144, 226, 0.3)' : 'none'
                }}
              >
                Register
              </Link>
            )}

            {vendorId && (
              <>
                <Link
                  to={`/dashboard/${vendorId}`}
                  className="px-4 py-2 font-medium transition-all duration-200 transform hover:scale-105"
                  style={{
                    borderRadius: '8px',
                    fontSize: '14px',
                    color: 'white',
                    background: location.pathname.includes('/dashboard') ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
                    fontWeight: location.pathname.includes('/dashboard') ? 600 : 500,
                    backdropFilter: location.pathname.includes('/dashboard') ? 'blur(10px)' : 'none',
                    border: location.pathname.includes('/dashboard') ? '1px solid rgba(255, 255, 255, 0.3)' : '1px solid transparent',
                    boxShadow: location.pathname.includes('/dashboard') ? '0 4px 15px rgba(74, 144, 226, 0.3)' : 'none'
                  }}
                >
                  Dashboard
                </Link>

                <Link
                  to={`/upload/${vendorId}`}
                  className="px-4 py-2 font-medium transition-all duration-200 transform hover:scale-105"
                  style={{
                    borderRadius: '8px',
                    fontSize: '14px',
                    color: 'white',
                    background: location.pathname.includes('/upload') ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
                    fontWeight: location.pathname.includes('/upload') ? 600 : 500,
                    backdropFilter: location.pathname.includes('/upload') ? 'blur(10px)' : 'none',
                    border: location.pathname.includes('/upload') ? '1px solid rgba(255, 255, 255, 0.3)' : '1px solid transparent',
                    boxShadow: location.pathname.includes('/upload') ? '0 4px 15px rgba(74, 144, 226, 0.3)' : 'none'
                  }}
                >
                  Upload
                </Link>

                <Link
                  to={`/risk/${vendorId}`}
                  className="px-4 py-2 font-medium transition-all duration-200 transform hover:scale-105"
                  style={{
                    borderRadius: '8px',
                    fontSize: '14px',
                    color: 'white',
                    background: location.pathname.includes('/risk') ? 'rgba(255, 255, 255, 0.2)' : 'transparent',
                    fontWeight: location.pathname.includes('/risk') ? 600 : 500,
                    backdropFilter: location.pathname.includes('/risk') ? 'blur(10px)' : 'none',
                    border: location.pathname.includes('/risk') ? '1px solid rgba(255, 255, 255, 0.3)' : '1px solid transparent',
                    boxShadow: location.pathname.includes('/risk') ? '0 4px 15px rgba(74, 144, 226, 0.3)' : 'none'
                  }}
                >
                  Risk Score
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  )
}

export default Navbar
