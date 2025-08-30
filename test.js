import http from "k6/http";
import { check, sleep } from "k6";

// Test configuration
export const options = {
    scenarios: {
    someInteraction: {
      executor: 'constant-arrival-rate',
      timeUnit: '1s',
      preAllocatedVUs: 10,
      maxVUs: 1000,
      rate: 10,
      duration: '60s',
      gracefulStop: '1m'
    },
  }
};

// Simulated user behavior
export default function () {
  let res = http.get("http://localhost:3000/reviews/?product_id=24");
  // Validate response status
  check(res, { "status was 200": (r) => r.status == 200 });
}