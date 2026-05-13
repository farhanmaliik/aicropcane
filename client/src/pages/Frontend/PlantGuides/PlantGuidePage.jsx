import React from 'react'
import { useNavigate, useParams, Navigate } from 'react-router-dom'

const plantGuides = {
  mango: {
    title: 'Mango Care & Fertilizer Tips',
    subtitle: 'Balanced fertilization, disease prevention and irrigation advice for mango orchards.',
    overview: 'Mango trees need a careful blend of nutrition, sun and moisture to produce healthy fruit. This guide covers common fungal diseases, mildew, and tree care so you can keep your orchard strong and flourishing.',
    issues: [
      {
        title: 'Anthracnose',
        description: 'Dark spots on leaves and fruit are symptoms of fungal infection. Prune damaged branches, improve airflow, and spray copper-based fungicide on new growth.',
      },
      {
        title: 'Powdery Mildew',
        description: 'White powder on leaves indicates too much humidity and poor air circulation. Reduce overhead watering and use potassium sulfate spray to protect new leaves.',
      },
      {
        title: 'Fruit Drop',
        description: 'Loss of young fruit often follows irregular watering or poor fertilizer balance. Keep soil evenly moist and feed with a nitrogen-phosphorus-potassium mix during flowering.',
      },
    ],
    remedies: [
      'Use well-rotted compost and neem cake around the root zone.',
      'Apply balanced NPK fertilizer in pre-flowering and fruit set stages.',
      'Spray organic fungicide or sulfur on susceptible trees every 10-14 days.',
    ],
    careTips: [
      'Water deeply once or twice per week, allowing the topsoil to dry slightly between irrigations.',
      'Mulch around trees to retain moisture and suppress weeds.',
      'Prune dead branches to improve air flow and reduce disease pressure.',
    ],
  },
  maize: {
    title: 'Maize Watering Tips',
    subtitle: 'Optimize irrigation, soil moisture, and fertilization for strong maize growth.',
    overview: 'Maize performs best with regular watering during key growth stages. Overwatering and water stress can both reduce yield, so this guide shares the best timing, nutrients, and pest defense for corn crops.',
    issues: [
      {
        title: 'Drought Stress',
        description: 'Yellowing lower leaves and stunted growth happen when maize is too dry. Water at the knee-height and tasseling stages to support healthy kernels.',
      },
      {
        title: 'Root Rot',
        description: 'Waterlogged soil can cause weak roots and plant collapse. Improve drainage and avoid soaking the field after heavy rain.',
      },
      {
        title: 'Leaf Blight',
        description: 'Brown lesions and early leaf death are usually fungal. Remove infected leaves and use a recommended fungicide spray.',
      },
    ],
    remedies: [
      'Apply a starter fertilizer rich in phosphorus at planting.',
      'Feed nitrogen at the V6 and V12 growth stages for strong stalks.',
      'Rotate crops and use organic mulch to keep pests and diseases low.',
    ],
    careTips: [
      'Irrigate early in the morning to reduce evaporation and fungal risk.',
      'Keep the soil moist but not waterlogged. Maize needs good drainage.',
      'Use a balanced fertilizer and avoid high nitrogen too late in the season.',
    ],
  },
  peas: {
    title: 'Peas Pest Control',
    subtitle: 'Protect pea plants from aphids, powdery mildew and soil-borne diseases.',
    overview: 'Peas are delicate and benefit from gentle pest control and good soil care. This guide focuses on pest prevention, disease treatment, and maintaining steady soil moisture for healthy green pods.',
    issues: [
      {
        title: 'Aphids',
        description: 'Sticky leaves and curled growth are caused by aphids. Spray with neem oil, introduce ladybugs, and avoid excess nitrogen fertilizer.',
      },
      {
        title: 'Powdery Mildew',
        description: 'A white coating on leaves reduces photosynthesis. Space plants wider, remove infected foliage, and spray potassium bicarbonate if needed.',
      },
      {
        title: 'Root Rot',
        description: 'Poor drainage and cold soil lead to weak roots. Plant in raised beds and keep soil light with organic matter.',
      },
    ],
    remedies: [
      'Use compost and bone meal to improve soil structure.',
      'Apply neem-based spray on early aphid infestations.',
      'Harvest on time and remove old plant debris to reduce pests.',
    ],
    careTips: [
      'Water gently at the base of the plant every 3-4 days.',
      'Support vines with a trellis to improve airflow.',
      'Plant peas early in cool weather and avoid wet, compacted soil.',
    ],
  },
  rice: {
    title: 'Rice Fertilizer Guide',
    subtitle: 'Nutrient management and disease care for thriving rice fields.',
    overview: 'Rice requires careful feeding and field management for good tiller development and grain filling. This guide helps you pick the right fertilizer schedule and treat common rice diseases safely.',
    issues: [
      {
        title: 'Blast Disease',
        description: 'Leaf and neck blast cause tan spots and broken stems. Use resistant varieties, balanced nitrogen, and remove infected plants promptly.',
      },
      {
        title: 'Brown Spot',
        description: 'Small brown lesions on leaves are often due to potassium deficiency. Apply potash and maintain proper soil moisture.',
      },
      {
        title: 'Bacterial Leaf Blight',
        description: 'Yellowing and drying leaves are symptoms of bacterial infection. Improve drainage and avoid excessive nitrogen after transplanting.',
      },
    ],
    remedies: [
      'Apply a balanced NPK fertilizer based on soil test results.',
      'Use organic green manure or compost before transplanting.',
      'Keep fields level and avoid prolonged flooding to reduce disease.',
    ],
    careTips: [
      'Maintain a shallow water layer during vegetative growth.',
      'Use alternate wetting and drying to save water and reduce disease.',
      'Feed small, frequent doses of fertilizer rather than one heavy dose.',
    ],
  },
}

export default function PlantGuidePage() {
  const { slug } = useParams()
  const navigate = useNavigate()
  const guide = plantGuides[slug]

  if (!guide) {
    return <Navigate to="/plant-guides" />
  }

  return (
    <div className='main-container py-20'>
      <button
        className='inline-flex items-center gap-2 text-[var(--secondary)] font-semibold mb-8'
        onClick={() => navigate('/plant-guides')}
      >
        ← Back to guides
      </button>

      <div className='bg-white p-8 rounded-[24px] shadow-sm'>
        <div className='max-w-4xl'>
          <h1 className='text-4xl font-semibold text-[var(--primary)]'>{guide.title}</h1>
          <p className='mt-4 text-gray-700 text-lg'>{guide.subtitle}</p>
          <p className='mt-6 text-gray-600 leading-relaxed'>{guide.overview}</p>

          <div className='grid gap-8 lg:grid-cols-3 mt-10'>
            <div className='p-6 border border-gray-200 rounded-[24px]'>
              <h2 className='text-xl font-semibold text-gray-900 mb-4'>Most common issues</h2>
              <div className='space-y-4'>
                {guide.issues.map((issue) => (
                  <div key={issue.title}>
                    <h3 className='font-semibold'>{issue.title}</h3>
                    <p className='mt-2 text-gray-600'>{issue.description}</p>
                  </div>
                ))}
              </div>
            </div>

            <div className='p-6 border border-gray-200 rounded-[24px]'>
              <h2 className='text-xl font-semibold text-gray-900 mb-4'>Treatment & medicine</h2>
              <ul className='list-disc list-inside space-y-3 text-gray-600'>
                {guide.remedies.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            </div>

            <div className='p-6 border border-gray-200 rounded-[24px]'>
              <h2 className='text-xl font-semibold text-gray-900 mb-4'>Quick care tips</h2>
              <ul className='list-disc list-inside space-y-3 text-gray-600'>
                {guide.careTips.map((item) => (
                  <li key={item}>{item}</li>
                ))}
              </ul>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
