import { useQuery } from "react-query";
import { axiosInstance } from "@/utils/url";
import { venueURL } from "@/utils/url/venue";
import { Venue } from "@/type";
import { AxiosError } from "axios";

const getVenues = async (userId?: number) => {
  const response = await axiosInstance.get(venueURL, { params: { userId } });
  return response.data;
};

export const useAPIGetVenues = (userId?: number) => {
  return useQuery<Venue[], AxiosError>({
    queryKey: ["venues"],
    queryFn: () => getVenues(userId),
  });
};
