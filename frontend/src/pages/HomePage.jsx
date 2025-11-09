import { Link } from 'react-router-dom'

const HomePage = () => {
  return (
    <div className="min-h-screen relative overflow-hidden" style={{ 
      background: 'linear-gradient(135deg, #003366 0%, #005EB8 50%, #4A90E2 100%)'
    }}>
      {/* Animated background elements */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute -top-40 -right-40 w-80 h-80 rounded-full opacity-20" style={{
          background: 'radial-gradient(circle, rgba(74, 144, 226, 0.4) 0%, transparent 70%)',
          animation: 'float 20s ease-in-out infinite'
        }}></div>
        <div className="absolute top-1/2 -left-40 w-96 h-96 rounded-full opacity-20" style={{
          background: 'radial-gradient(circle, rgba(92, 184, 92, 0.3) 0%, transparent 70%)',
          animation: 'float 25s ease-in-out infinite',
          animationDelay: '5s'
        }}></div>
        <div className="absolute bottom-20 right-1/4 w-64 h-64 rounded-full opacity-20" style={{
          background: 'radial-gradient(circle, rgba(245, 166, 35, 0.3) 0%, transparent 70%)',
          animation: 'float 30s ease-in-out infinite',
          animationDelay: '10s'
        }}></div>
      </div>

      <div className="container mx-auto px-4 py-16 relative z-10">
        {/* Hero Section */}
        <div className="text-center mb-20">
          {/* Premium badge with enhanced glass */}
          <div className="inline-block mb-6 px-6 py-3 rounded-full animate-pulse" style={{
            background: 'linear-gradient(135deg, rgba(255, 255, 255, 0.2) 0%, rgba(255, 255, 255, 0.1) 100%)',
            backdropFilter: 'blur(20px)',
            WebkitBackdropFilter: 'blur(20px)',
            border: '1.5px solid rgba(255, 255, 255, 0.4)',
            boxShadow: '0 8px 32px rgba(74, 144, 226, 0.3), inset 0 1px 0 rgba(255, 255, 255, 0.3)'
          }}>
            <span style={{ 
              color: 'white',
              fontSize: '14px',
              fontWeight: 600,
              letterSpacing: '0.5px'
            }}>⚡ ENTERPRISE-GRADE AUTOMATION</span>
          </div>

          <h1 className="mb-6" style={{ 
            color: 'white',
            fontSize: '56px',
            fontWeight: 700,
            lineHeight: '1.2',
            fontFamily: 'Poppins, Inter, system-ui, sans-serif',
            textShadow: '0 4px 20px rgba(0, 0, 0, 0.3)'
          }}>
            Automated Vendor<br/>Onboarding Platform
          </h1>
          <p className="mb-4" style={{ 
            color: 'rgba(255, 255, 255, 0.9)',
            fontSize: '24px',
            fontWeight: 500,
            textShadow: '0 2px 10px rgba(0, 0, 0, 0.2)'
          }}>
            Transform vendor onboarding from <span style={{ color: '#F5A623', fontWeight: 700 }}>6 months</span> to <span style={{ color: '#5CB85C', fontWeight: 700 }}>2 weeks</span>
          </p>
          <p className="max-w-3xl mx-auto mb-10" style={{ 
            color: 'rgba(255, 255, 255, 0.8)',
            fontSize: '16px',
            lineHeight: '1.6'
          }}>
            Streamlined workflows, intelligent automation, and real-time compliance verification
          </p>
          
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link to="/register" className="btn-primary text-lg px-10 py-4 inline-block transform hover:scale-105 hover:shadow-2xl transition-all duration-300" style={{
              background: 'linear-gradient(135deg, #4A90E2 0%, #357ABD 100%)',
              boxShadow: '0 8px 32px rgba(74, 144, 226, 0.4)',
              borderRadius: '12px',
              color: 'white',
              fontWeight: 600
            }}>
              Start Onboarding Process →
            </Link>
            
            <Link to="/dashboard" className="text-lg px-10 py-4 inline-block transform hover:scale-105 transition-all duration-300" style={{
              background: 'rgba(255, 255, 255, 0.1)',
              backdropFilter: 'blur(10px)',
              WebkitBackdropFilter: 'blur(10px)',
              border: '2px solid rgba(255, 255, 255, 0.3)',
              borderRadius: '12px',
              color: 'white',
              fontWeight: 600,
              boxShadow: '0 8px 32px rgba(0, 0, 0, 0.1)'
            }}>
              View Demo Dashboard
            </Link>
          </div>
        </div>

        {/* Benefits Grid with Enhanced Glass Cards */}
        <div className="grid md:grid-cols-3 gap-6 mb-20">
          <div className="group relative overflow-hidden transition-all duration-500 hover:transform hover:scale-105 hover:-translate-y-3" style={{
            background: 'linear-gradient(135deg, rgba(255, 255, 255, 0.12) 0%, rgba(255, 255, 255, 0.06) 100%)',
            backdropFilter: 'blur(30px) saturate(200%)',
            WebkitBackdropFilter: 'blur(30px) saturate(200%)',
            border: '1px solid rgba(255, 255, 255, 0.25)',
            borderRadius: '20px',
            padding: '32px',
            boxShadow: '0 8px 32px rgba(0, 0, 0, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.2)',
            borderLeft: '4px solid #4A90E2'
          }}>
            <div className="absolute top-0 right-0 w-32 h-32 opacity-10 group-hover:opacity-20 transition-opacity" style={{
              background: 'radial-gradient(circle, #4A90E2 0%, transparent 70%)',
              filter: 'blur(40px)'
            }}></div>
            <div className="relative z-10">
              <div className="mb-4" style={{ fontSize: '48px' }}>⚡</div>
              <h3 className="mb-3" style={{ 
                color: 'white',
                fontSize: '22px',
                fontWeight: 700,
                fontFamily: 'Poppins, Inter, system-ui, sans-serif'
              }}>85% Time Reduction</h3>
              <p style={{ 
                color: 'rgba(255, 255, 255, 0.85)',
                fontSize: '15px',
                lineHeight: '1.6'
              }}>
                Cut onboarding time from 6 months to just 2 weeks with AI-powered automation
              </p>
            </div>
          </div>

          <div className="group relative overflow-hidden transition-all duration-500 hover:transform hover:scale-105 hover:-translate-y-3" style={{
            background: 'linear-gradient(135deg, rgba(255, 255, 255, 0.12) 0%, rgba(255, 255, 255, 0.06) 100%)',
            backdropFilter: 'blur(30px) saturate(200%)',
            WebkitBackdropFilter: 'blur(30px) saturate(200%)',
            border: '1px solid rgba(255, 255, 255, 0.25)',
            borderRadius: '20px',
            padding: '32px',
            boxShadow: '0 8px 32px rgba(0, 0, 0, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.2)',
            borderLeft: '4px solid #5CB85C'
          }}>
            <div className="absolute top-0 right-0 w-32 h-32 opacity-10 group-hover:opacity-20 transition-opacity" style={{
              background: 'radial-gradient(circle, #5CB85C 0%, transparent 70%)',
              filter: 'blur(40px)'
            }}></div>
            <div className="relative z-10">
              <svg className="mb-4" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#5CB85C" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <polyline points="20 6 9 17 4 12"></polyline>
              </svg>
              <h3 className="mb-3" style={{ 
                color: 'white',
                fontSize: '22px',
                fontWeight: 700,
                fontFamily: 'Poppins, Inter, system-ui, sans-serif'
              }}>Automated Verification</h3>
              <p style={{ 
                color: 'rgba(255, 255, 255, 0.85)',
                fontSize: '15px',
                lineHeight: '1.6'
              }}>
                Intelligent document processing and real-time compliance checking
              </p>
            </div>
          </div>

          <div className="group relative overflow-hidden transition-all duration-500 hover:transform hover:scale-105 hover:-translate-y-3" style={{
            background: 'linear-gradient(135deg, rgba(255, 255, 255, 0.12) 0%, rgba(255, 255, 255, 0.06) 100%)',
            backdropFilter: 'blur(30px) saturate(200%)',
            WebkitBackdropFilter: 'blur(30px) saturate(200%)',
            border: '1px solid rgba(255, 255, 255, 0.25)',
            borderRadius: '20px',
            padding: '32px',
            boxShadow: '0 8px 32px rgba(0, 0, 0, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.2)',
            borderLeft: '4px solid #F5A623'
          }}>
            <div className="absolute top-0 right-0 w-32 h-32 opacity-10 group-hover:opacity-20 transition-opacity" style={{
              background: 'radial-gradient(circle, #F5A623 0%, transparent 70%)',
              filter: 'blur(40px)'
            }}></div>
            <div className="relative z-10">
              <svg className="mb-4" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#F5A623" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <line x1="5" y1="12" x2="19" y2="12"></line>
                <polyline points="12 5 19 12 12 19"></polyline>
              </svg>
              <h3 className="mb-3" style={{ 
                color: 'white',
                fontSize: '22px',
                fontWeight: 700,
                fontFamily: 'Poppins, Inter, system-ui, sans-serif'
              }}>Seamless Workflows</h3>
              <p style={{ 
                color: 'rgba(255, 255, 255, 0.85)',
                fontSize: '15px',
                lineHeight: '1.6'
              }}>
                End-to-end automation from submission to approval
              </p>
            </div>
          </div>
        </div>

        {/* Process Steps - Ultra Premium Glass Card */}
        <div className="mb-20 relative overflow-hidden group" style={{
          background: 'linear-gradient(135deg, rgba(255, 255, 255, 0.15) 0%, rgba(255, 255, 255, 0.08) 100%)',
          backdropFilter: 'blur(40px) saturate(200%)',
          WebkitBackdropFilter: 'blur(40px) saturate(200%)',
          border: '2px solid rgba(255, 255, 255, 0.3)',
          borderRadius: '28px',
          padding: '56px',
          boxShadow: '0 20px 60px rgba(0, 0, 0, 0.2), inset 0 1px 0 rgba(255, 255, 255, 0.3), inset 0 -1px 0 rgba(0, 0, 0, 0.1)'
        }}>
          <h2 className="text-center mb-12" style={{ 
            color: 'white',
            fontSize: '36px',
            fontWeight: 700,
            fontFamily: 'Poppins, Inter, system-ui, sans-serif',
            textShadow: '0 2px 20px rgba(0, 0, 0, 0.2)'
          }}>
            Simple 4-Step Process
          </h2>

          <div className="grid md:grid-cols-4 gap-8">
            {[
              { num: 1, title: 'Register', desc: 'Submit your company information and create an account' },
              { num: 2, title: 'Upload Documents', desc: 'AI extracts and verifies your compliance documents' },
              { num: 3, title: 'Risk Assessment', desc: 'Automated scoring across financial, cyber, and ESG dimensions' },
              { num: 4, title: 'Track Progress', desc: 'Monitor your onboarding status in real-time' }
            ].map((step, i) => (
              <div key={i} className="text-center group">
                <div className="mx-auto mb-4 flex items-center justify-center transform group-hover:scale-110 transition-transform duration-300" style={{
                  width: '72px',
                  height: '72px',
                  borderRadius: '50%',
                  background: 'linear-gradient(135deg, rgba(74, 144, 226, 0.9) 0%, rgba(53, 122, 189, 0.9) 100%)',
                  color: 'white',
                  fontSize: '28px',
                  fontWeight: 700,
                  boxShadow: '0 8px 24px rgba(74, 144, 226, 0.4), inset 0 -2px 8px rgba(0, 0, 0, 0.2)',
                  border: '2px solid rgba(255, 255, 255, 0.3)'
                }}>
                  {step.num}
                </div>
                <h4 className="mb-2" style={{ 
                  color: 'white',
                  fontSize: '18px',
                  fontWeight: 600,
                  fontFamily: 'Poppins, Inter, system-ui, sans-serif'
                }}>{step.title}</h4>
                <p style={{ 
                  color: 'rgba(255, 255, 255, 0.75)',
                  fontSize: '14px',
                  lineHeight: '1.5'
                }}>
                  {step.desc}
                </p>
              </div>
            ))}
          </div>

          <div className="text-center mt-12">
            <Link to="/register" className="btn-primary inline-block transform hover:scale-105 transition-all duration-300" style={{
              background: 'linear-gradient(135deg, #5CB85C 0%, #4FA84F 100%)',
              boxShadow: '0 8px 24px rgba(92, 184, 92, 0.4)',
              borderRadius: '12px',
              padding: '14px 32px',
              color: 'white',
              fontWeight: 600,
              fontSize: '16px'
            }}>
              Get Started Now
            </Link>
          </div>
        </div>

        {/* Features Section - Ultra Glass Cards */}
        <div className="grid md:grid-cols-2 gap-6">
          <div className="relative overflow-hidden group transition-all duration-500 hover:transform hover:scale-102" style={{
            background: 'linear-gradient(135deg, rgba(255, 255, 255, 0.12) 0%, rgba(255, 255, 255, 0.06) 100%)',
            backdropFilter: 'blur(30px) saturate(200%)',
            WebkitBackdropFilter: 'blur(30px) saturate(200%)',
            border: '1px solid rgba(255, 255, 255, 0.25)',
            borderRadius: '20px',
            padding: '36px',
            boxShadow: '0 8px 32px rgba(0, 0, 0, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.2)'
          }}>
            <h3 className="mb-6" style={{ 
              color: 'white',
              fontSize: '22px',
              fontWeight: 700,
              fontFamily: 'Poppins, Inter, system-ui, sans-serif'
            }}>Key Features</h3>
            <ul className="space-y-4">
              {[
                'Unified KY3P and SLP platform integration',
                'AWS Textract for intelligent document processing',
                'Real-time compliance and sanctions screening',
                'Comprehensive audit trail and CloudTrail logging'
              ].map((feature, i) => (
                <li key={i} className="flex items-start group">
                  <div className="flex-shrink-0 mr-3 mt-1 transform group-hover:scale-110 transition-transform">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#5CB85C" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                      <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                  </div>
                  <span style={{ color: 'rgba(255, 255, 255, 0.9)', fontSize: '15px', lineHeight: '1.6' }}>{feature}</span>
                </li>
              ))}
            </ul>
          </div>

          <div className="relative overflow-hidden group transition-all duration-500 hover:transform hover:scale-102" style={{
            background: 'linear-gradient(135deg, rgba(255, 255, 255, 0.12) 0%, rgba(255, 255, 255, 0.06) 100%)',
            backdropFilter: 'blur(30px) saturate(200%)',
            WebkitBackdropFilter: 'blur(30px) saturate(200%)',
            border: '1px solid rgba(255, 255, 255, 0.25)',
            borderRadius: '20px',
            padding: '36px',
            boxShadow: '0 8px 32px rgba(0, 0, 0, 0.15), inset 0 1px 0 rgba(255, 255, 255, 0.2)'
          }}>
            <h3 className="mb-6" style={{ 
              color: 'white',
              fontSize: '22px',
              fontWeight: 700,
              fontFamily: 'Poppins, Inter, system-ui, sans-serif'
            }}>Security Highlights</h3>
            <ul className="space-y-4">
              {[
                'Customer-managed AWS KMS encryption keys',
                '3-tier VPC architecture with isolated subnets',
                'IAM least privilege access controls',
                'Serverless architecture for maximum security'
              ].map((feature, i) => (
                <li key={i} className="flex items-start group">
                  <div className="flex-shrink-0 mr-3 mt-1 transform group-hover:scale-110 transition-transform">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#5CB85C" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                      <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                  </div>
                  <span style={{ color: 'rgba(255, 255, 255, 0.9)', fontSize: '15px', lineHeight: '1.6' }}>{feature}</span>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>

      <style>{`
        @keyframes float {
          0%, 100% { transform: translateY(0px) translateX(0px); }
          33% { transform: translateY(-20px) translateX(10px); }
          66% { transform: translateY(-10px) translateX(-10px); }
        }
      `}</style>
    </div>
  )
}

export default HomePage
