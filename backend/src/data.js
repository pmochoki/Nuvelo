const categories = [
  { id: "rentals", name: "Rentals" },
  { id: "jobs", name: "Jobs" },
  { id: "clothes", name: "Clothes" },
  { id: "services", name: "Services" },
  { id: "electronics", name: "Electronics" },
  { id: "vehicles", name: "Vehicles" },
  { id: "real-estate", name: "Real estate" }
];

const users = [
  { id: "u1", name: "Anna Nagy", role: "landlord", banned: false },
  { id: "u2", name: "David Smith", role: "seller", banned: false }
];

const listings = [
  {
    id: "l1",
    title: "City center studio",
    description: "Bright studio near tram line.",
    categoryId: "rentals",
    price: 450,
    currency: "EUR",
    location: "Budapest",
    images: [],
    condition: "good",
    categoryFields: {
      type: "studio",
      bedrooms: 1,
      bathrooms: 1,
      area: 28,
      furnished: true,
      lease: "long-term"
    },
    userId: "u1",
    status: "approved",
    createdAt: new Date().toISOString()
  },
  {
    id: "l2",
    title: "Part-time barista",
    description: "Weekend shift, English speaking.",
    categoryId: "jobs",
    price: null,
    currency: "HUF",
    location: "Debrecen",
    images: [],
    condition: "new",
    categoryFields: {
      role: "Barista",
      contractType: "part-time",
      salaryRange: "HUF 2000/hour",
      experience: "1+ year"
    },
    userId: "u2",
    status: "approved",
    createdAt: new Date().toISOString()
  },
  {
    id: "l3",
    title: "Toyota Corolla 2016",
    description: "Reliable, single owner, serviced regularly.",
    categoryId: "vehicles",
    price: 4100000,
    currency: "HUF",
    location: "Szeged",
    images: [],
    condition: "used",
    categoryFields: {
      make: "Toyota",
      model: "Corolla",
      year: 2016,
      mileage: 98000,
      transmission: "automatic",
      fuel: "gasoline"
    },
    userId: "u2",
    status: "approved",
    createdAt: new Date().toISOString()
  },
  {
    id: "l4",
    title: "iPhone 12 128GB",
    description: "Blue, battery 88%, includes charger.",
    categoryId: "electronics",
    price: 165000,
    currency: "HUF",
    location: "Budapest",
    images: [],
    condition: "good",
    categoryFields: {
      brand: "Apple",
      model: "iPhone 12",
      storage: "128GB",
      warranty: "No"
    },
    userId: "u2",
    status: "approved",
    createdAt: new Date().toISOString()
  }
];

const conversations = [];
const messages = [];
const reports = [];
const favorites = [];
const savedSearches = [];
const blocks = [];

module.exports = {
  categories,
  users,
  listings,
  conversations,
  messages,
  reports,
  favorites,
  savedSearches,
  blocks
};
