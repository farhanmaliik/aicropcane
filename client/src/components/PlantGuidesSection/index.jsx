import React from 'react'
import { useNavigate } from 'react-router-dom'
import { FaLeaf, FaTint, FaBug, FaSeedling, FaYoutube } from 'react-icons/fa'

const guideCards = [
  {
    slug: 'mango',
    title: 'Mango Care & Fertilizer Tips',
    short: 'Healthy mango plants need balanced nutrition, good pruning, and disease prevention.',
    icon: FaLeaf,
  },
  {
    slug: 'maize',
    title: 'Maize Watering Tips',
    short: 'Maize thrives when watering is timed around soil moisture and seasonal heat.',
    icon: FaTint,
  },
  {
    slug: 'peas',
    title: 'Peas Pest Control',
    short: 'Protect peas from aphids and wilts with simple, safe crop care routines.',
    icon: FaBug,
  },
  {
    slug: 'rice',
    title: 'Rice Fertilizer Guide',
    short: 'Rice needs nitrogen, phosphorus, and potassium at the right stages.',
    icon: FaSeedling,
  },
]

const videos = [
  {
    title: 'Mango Farming Tips for Higher Yield',
    description: 'Learn fertilizer schedules, pruning, and disease prevention for mango orchards.',
    videoId: 'RdkLuktC6RM',
  },
  {
    title: 'Maize Cultivation Best Practices',
    description: 'Growth techniques, watering strategies and pest control for corn fields.',
    videoId: '9V6jLw-5-hg',
  },
  {
    title: 'Organic Pest Control for Crops',
    description: 'Safe spray schedules, natural remedies and simple field treatments.',
    videoId: '5U1JjNzfEP8',
  },
]

export default function PlantGuidesSection({ showVideos = true }) {
  const navigate = useNavigate()

  return (
    <div className='main-container py-20'>
      <div className='text-center'>
        <h2 className='text-[var(--primary)] text-3xl sm:text-4xl font-semibold'>Plant Guides for Fruit & Crop Health</h2>
        <p className='mt-4 text-gray-700 max-w-3xl mx-auto text-[18px]'>Choose a plant card to open a dedicated guide page with common problems, treatment options, and practical care tips for better results.</p>
      </div>

      <div className='grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mt-12'>
        {guideCards.map((item) => {
          const Icon = item.icon
          return (
            <button
              key={item.slug}
              onClick={() => navigate(`/plant-guides/${item.slug}`)}
              className='group flex flex-col justify-between items-start p-6 h-full bg-white border border-gray-200 rounded-[24px] text-left shadow-sm transition-all duration-200 hover:-translate-y-1 hover:shadow-lg'
            >
              <div className='flex items-center justify-center w-14 h-14 rounded-full bg-[var(--x-light)] text-[var(--secondary)] mb-6'>
                <Icon className='text-2xl' />
              </div>
              <div>
                <h3 className='text-xl font-semibold text-gray-900'>{item.title}</h3>
                <p className='mt-3 text-gray-600 leading-relaxed'>{item.short}</p>
              </div>
              <span className='mt-6 text-[var(--secondary)] font-medium group-hover:text-[var(--primary)]'>Open guide →</span>
            </button>
          )
        })}
      </div>

      {showVideos && (
        <div className='mt-20'>
          <div className='flex flex-col sm:flex-row sm:items-end sm:justify-between gap-4'>
            <div>
              <h2 className='text-[var(--primary)] text-3xl sm:text-4xl font-semibold'>Farming Videos</h2>
              <p className='mt-3 text-gray-700 max-w-2xl'>Watch short practical videos from farming experts to support crop care, disease prevention, and irrigation planning.</p>
            </div>
            <div className='flex items-center gap-2 text-[var(--secondary)] font-semibold'>
              <FaYoutube className='text-2xl' />
              <span>YouTube picks</span>
            </div>
          </div>

          <div className='grid grid-cols-1 md:grid-cols-3 gap-6 mt-10'>
            {videos.map((video) => (
              <a
                key={video.videoId}
                href={`https://www.youtube.com/watch?v=${video.videoId}`}
                target='_blank'
                rel='noreferrer'
                className='group block overflow-hidden rounded-[24px] border border-gray-200 bg-white shadow-sm transition-all duration-200 hover:shadow-lg'
              >
                <div className='relative h-52 bg-black'>
                  <img
                    src={`https://img.youtube.com/vi/${video.videoId}/hqdefault.jpg`}
                    alt={video.title}
                    className='w-full h-full object-cover'
                  />
                  <div className='absolute inset-0 bg-black/20 flex items-center justify-center text-white text-4xl opacity-0 group-hover:opacity-100 transition-opacity duration-200'>
                    <FaYoutube />
                  </div>
                </div>
                <div className='p-5'>
                  <h3 className='text-lg font-semibold text-gray-900'>{video.title}</h3>
                  <p className='mt-3 text-gray-600'>{video.description}</p>
                </div>
              </a>
            ))}
          </div>
        </div>
      )}
    </div>
  )
}
