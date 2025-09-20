import { useMutation, UseMutationOptions } from "react-query";
import { axiosInstance } from "@/utils/url";
import { venueURL } from "@/utils/url/venue";
import { Venue } from "@/type";
import { AxiosError } from "axios";
import { jsonHeader } from "@/utils/url/header";

export interface UpdateVenueRequest {
  name?: string;
  address?: string;
  tel?: string;
  description?: string;
  capacity?: number;
  facilities?: string;
  availableTime?: string;
  imageUrl?: string;
}

const updateVenue = async (body: { id: string; data: UpdateVenueRequest }) => {
  const headers = await jsonHeader;
  const response = await axiosInstance.patch(
    venueURL + "/" + body.id,
    body.data,
    {
      headers,
    }
  );
  return response.data;
};

export const useAPIUpdateVenue = (
  mutationOptions?: UseMutationOptions<
    Venue,
    AxiosError,
    { id: string; data: UpdateVenueRequest }
  >
) => {
  return useMutation<
    Venue,
    AxiosError,
    { id: string; data: UpdateVenueRequest }
  >(updateVenue, mutationOptions);
};
